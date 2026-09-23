import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../core/constants/robot_constants.dart';
import '../core/utils/file_saver.dart';
import '../data/models/robot_command.dart';
import '../data/models/robot_status.dart';
import '../data/services/mjpeg_stream_service.dart';
import '../data/services/mock_robot_service.dart';
import '../data/services/robot_api_service.dart';

class RobotController extends ChangeNotifier {
  RobotController({
    RobotApiService? apiService,
    MjpegStreamService? streamService,
    MockRobotService? mockService,
  })  : _api = apiService ?? RobotApiService(),
        _stream = streamService ?? MjpegStreamService(),
        _mock = mockService ?? MockRobotService() {
    _init();
  }

  final RobotApiService _api;
  final MjpegStreamService _stream;
  final MockRobotService _mock;

  // Telemetry state
  RobotTelemetry _telemetry = const RobotTelemetry();
  RobotTelemetry get telemetry => _telemetry;

  // Active video frame
  Uint8List? _currentFrame;
  Uint8List? get currentFrame => _currentFrame;

  // Frame buffer for video recording
  final List<Uint8List> _recordedFrames = [];
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;

  // Command loop timer & ping timer
  Timer? _commandLoopTimer;
  Timer? _pingTimer;
  String _lastSentCommandCode = '';
  int _lastSentCommandTime = 0;

  // UI state
  bool _useJoystick = false;
  bool get useJoystick => _useJoystick;
  set useJoystick(bool val) {
    _useJoystick = val;
    notifyListeners();
  }

  bool _isSimulatorMode = false;
  bool get isSimulatorMode => _isSimulatorMode;

  String get hostUrl => _api.baseUrl;

  bool _isAutopilotExecuting = false;

  void _init() {
    _startCommandLoop();
    _startPingMonitor();
    // Immediate connection check on launch (don't wait 4s)
    unawaited(_checkPingNow());
  }

  void setSimulatorMode(bool enable) {
    _isSimulatorMode = enable;
    if (_isSimulatorMode) {
      _stream.stopStream();
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.simulated,
        latencyMs: 5,
      );
      if (_telemetry.isCamOn) {
        _startMockStream();
      }
    } else {
      _mock.stopMockStream();
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.disconnected,
      );
      if (_telemetry.isCamOn) {
        _startHttpStream();
      }
      unawaited(_checkPingNow());
    }
    notifyListeners();
  }

  void updateHostUrl(String newUrl) {
    _api.updateBaseUrl(newUrl);
    if (!_isSimulatorMode && _telemetry.isCamOn) {
      _startHttpStream();
    }
    unawaited(_checkPingNow());
    notifyListeners();
  }

  /// Fast parallel scan across common vehicle host addresses:
  /// mDNS (`pametno-vozilo.local`), Pi AP (`192.168.4.1`), direct IP (`192.168.1.105`), and localhost.
  /// Connects within <= 2 seconds to whichever answers first.
  Future<String?> fastScanAndConnect() async {
    if (_isSimulatorMode) return 'Simulator Active';

    _telemetry = _telemetry.copyWith(connectionStatus: RobotConnectionStatus.connecting);
    notifyListeners();

    final candidates = <String>{
      _api.baseUrl,
      RobotConstants.defaultHost,
      'http://192.168.4.1:1607',
      'http://192.168.1.105:1607',
      'http://localhost:1607',
      'http://10.0.2.2:1607',
    }.toList();

    final result = await _api.fastProbeCandidates(candidates);

    if (result != null) {
      _api.updateBaseUrl(result.host);
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.connected,
        latencyMs: result.latencyMs,
        lastError: null,
      );
      if (_telemetry.isCamOn) {
        await _startHttpStream();
      }
      notifyListeners();
      return result.host;
    } else {
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.disconnected,
        latencyMs: null,
        lastError: 'No vehicle responded on scanned addresses',
      );
      notifyListeners();
      return null;
    }
  }

  // --- Movement Commands ---

  void setCommand(RobotCommand cmd) {
    if (_telemetry.currentCommand == cmd) return;
    _telemetry = _telemetry.copyWith(currentCommand: cmd);
    _mock.updateCommand(cmd);
    notifyListeners();
  }

  void stopMoving() {
    setCommand(RobotCommand.stop);
  }

  void handleJoystick(double offX, double offY, double radius) {
    final distSq = (offX * offX) + (offY * offY);
    if (distSq < (RobotConstants.joystickDeadzone * RobotConstants.joystickDeadzone)) {
      if (_telemetry.currentCommand != RobotCommand.stop) {
        stopMoving();
      }
      return;
    }

    RobotCommand targetCmd;
    if (offY.abs() > offX.abs()) {
      targetCmd = offY < 0 ? RobotCommand.forward : RobotCommand.backward;
    } else {
      targetCmd = offX > 0 ? RobotCommand.right : RobotCommand.left;
    }

    if (_telemetry.currentCommand != targetCmd) {
      setCommand(targetCmd);
    }
  }

  // --- Background Command Loop ---

  void _startCommandLoop() {
    _commandLoopTimer?.cancel();
    _commandLoopTimer = Timer.periodic(RobotConstants.commandLoopInterval, (timer) async {
      final cmd = _telemetry.currentCommand;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (cmd.code != _lastSentCommandCode ||
          (cmd != RobotCommand.stop && (now - _lastSentCommandTime) > RobotConstants.commandKeepAliveInterval.inMilliseconds)) {
        _lastSentCommandCode = cmd.code;
        _lastSentCommandTime = now;

        if (_isSimulatorMode) {
          _mock.updateCommand(cmd);
        } else {
          await _api.sendCommand(cmd.code);
        }
      }
    });
  }

  // --- Camera & Video Streaming ---

  Future<void> toggleCamera() async {
    if (_telemetry.isCamOn) {
      await stopCamera();
    } else {
      await startCamera();
    }
  }

  Future<void> startCamera() async {
    _telemetry = _telemetry.copyWith(isCamOn: true);
    notifyListeners();

    if (_isSimulatorMode) {
      _startMockStream();
    } else {
      await _startHttpStream();
    }
  }

  Future<void> stopCamera() async {
    if (_isSimulatorMode) {
      _mock.stopMockStream();
    } else {
      await _stream.stopStream();
    }

    if (_telemetry.isRecording) {
      await stopRecording();
    }

    _currentFrame = null;
    _telemetry = _telemetry.copyWith(
      isCamOn: false,
      streamFps: 0.0,
      isDetectionOn: false,
      isFollowOn: false,
      isOcrRunning: false,
      isAutopilotRunning: false,
      ocrDetectedText: '',
    );

    if (!_isSimulatorMode) {
      await _api.toggleDetection(false);
      await _api.toggleFollow(false);
    }

    notifyListeners();
  }

  Future<void> _startHttpStream() async {
    _telemetry = _telemetry.copyWith(
      connectionStatus: RobotConnectionStatus.connecting,
    );
    notifyListeners();

    await _stream.startStream(
      baseUrl: _api.baseUrl,
      onConnected: () {
        _telemetry = _telemetry.copyWith(
          connectionStatus: RobotConnectionStatus.connected,
          lastError: null,
        );
        notifyListeners();
      },
      onFrame: _handleNewFrame,
      onError: (err) {
        if (!_stream.isActive) {
          _telemetry = _telemetry.copyWith(
            connectionStatus: RobotConnectionStatus.disconnected,
            lastError: err,
            streamFps: 0.0,
          );
        } else {
          // Seamlessly auto-reconnecting in background (bypassing 5-minute limit)
          _telemetry = _telemetry.copyWith(
            lastError: err,
          );
        }
        notifyListeners();
      },
    );
  }

  void _startMockStream() {
    _mock.startMockStream(
      onConnected: () {
        _telemetry = _telemetry.copyWith(
          connectionStatus: RobotConnectionStatus.simulated,
          lastError: null,
        );
        notifyListeners();
      },
      onFrame: _handleNewFrame,
    );
  }

  void _handleNewFrame(Uint8List frameBytes, double fps) {
    _currentFrame = frameBytes;
    _telemetry = _telemetry.copyWith(streamFps: fps);

    // Buffer frame if recording
    if (_telemetry.isRecording) {
      if (_recordedFrames.length < 300) {
        _recordedFrames.add(Uint8List.fromList(frameBytes));
        _telemetry = _telemetry.copyWith(
          recordedFramesCount: _recordedFrames.length,
        );
      }
    }

    notifyListeners();
  }

  // --- Remote AI Toggles ---

  Future<void> toggleDetection(bool enable) async {
    if (_isSimulatorMode) {
      _mock.setVision(enable);
      _telemetry = _telemetry.copyWith(
        isDetectionOn: enable,
        isFollowOn: enable ? _telemetry.isFollowOn : false,
      );
      notifyListeners();
      return;
    }

    final success = await _api.toggleDetection(enable);
    if (success) {
      _telemetry = _telemetry.copyWith(isDetectionOn: enable);
      if (!enable && _telemetry.isFollowOn) {
        await toggleFollow(false);
      }
      notifyListeners();
    }
  }

  Future<void> toggleFollow(bool enable) async {
    if (!enable) {
      if (_isSimulatorMode) {
        _mock.setFollow(false);
        _telemetry = _telemetry.copyWith(isFollowOn: false);
        notifyListeners();
      } else {
        final success = await _api.toggleFollow(false);
        if (success) {
          _telemetry = _telemetry.copyWith(isFollowOn: false);
          notifyListeners();
        }
      }
      return;
    }

    // Safety: only allow follow if detection is active
    if (!_telemetry.isDetectionOn) {
      await toggleDetection(true);
    }

    if (_isSimulatorMode) {
      _mock.setFollow(true);
      _telemetry = _telemetry.copyWith(isFollowOn: true);
      notifyListeners();
      return;
    }

    final success = await _api.toggleFollow(true);
    if (success) {
      _telemetry = _telemetry.copyWith(isFollowOn: true);
      notifyListeners();
    }
  }

  // --- OCR & Autopilot ---

  void toggleOcr() {
    final next = !_telemetry.isOcrRunning;
    _telemetry = _telemetry.copyWith(
      isOcrRunning: next,
      isAutopilotRunning: next ? _telemetry.isAutopilotRunning : false,
      ocrDetectedText: next ? _telemetry.ocrDetectedText : '',
    );
    notifyListeners();
  }

  void toggleAutopilot() {
    final next = !_telemetry.isAutopilotRunning;
    _telemetry = _telemetry.copyWith(
      isAutopilotRunning: next,
      isOcrRunning: next ? true : _telemetry.isOcrRunning,
    );
    if (!next) {
      stopMoving();
    }
    notifyListeners();
  }

  /// Injects detected OCR text (from image recognition, mock, or manual input)
  /// Triggers autopilot state machine if active.
  Future<void> injectOcrResult(String rawText) async {
    if (!_telemetry.isOcrRunning) return;

    final trimmed = rawText.trim();
    _telemetry = _telemetry.copyWith(ocrDetectedText: trimmed);
    notifyListeners();

    if (_telemetry.isAutopilotRunning && trimmed.isNotEmpty && !_isAutopilotExecuting) {
      await _executeAutopilotStep(trimmed.toLowerCase());
    }
  }

  Future<void> _executeAutopilotStep(String text) async {
    _isAutopilotExecuting = true;

    RobotCommand? target;
    if (text.contains('rotate')) {
      target = RobotCommand.rotateRight;
    } else if (text.contains('left')) {
      target = RobotCommand.left;
    } else if (text.contains('right')) {
      target = RobotCommand.right;
    } else if (text.contains('back')) {
      target = RobotCommand.backward;
    } else if (text.contains('forward')) {
      target = RobotCommand.forward;
    }

    if (target != null) {
      setCommand(target);
      await Future.delayed(RobotConstants.autopilotDriveDuration);

      setCommand(RobotCommand.stop);
      await Future.delayed(RobotConstants.autopilotPauseDuration);

      _telemetry = _telemetry.copyWith(ocrDetectedText: '');
      notifyListeners();
    }

    _isAutopilotExecuting = false;
  }

  // --- Snapshot & Recording ---

  Future<String?> captureSnapshot() async {
    final frame = _currentFrame;
    if (frame == null) return null;

    final filename = 'PI_CAP_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = await FileSaver.save(
      bytes: frame,
      filename: filename,
      mimeType: 'image/jpeg',
    );
    return savedPath ?? filename;
  }

  Future<void> startRecording() async {
    if (_telemetry.isRecording) return;
    _recordedFrames.clear();
    _recordingStartTime = DateTime.now();

    _telemetry = _telemetry.copyWith(
      isRecording: true,
      recordingDuration: Duration.zero,
      recordedFramesCount: 0,
    );
    notifyListeners();

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingStartTime != null) {
        _telemetry = _telemetry.copyWith(
          recordingDuration: DateTime.now().difference(_recordingStartTime!),
        );
        notifyListeners();
      }
    });
  }

  Future<String?> stopRecording() async {
    if (!_telemetry.isRecording) return null;
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final framesToEncode = List<Uint8List>.from(_recordedFrames);
    _recordedFrames.clear();

    _telemetry = _telemetry.copyWith(
      isRecording: false,
      recordingDuration: Duration.zero,
      recordedFramesCount: 0,
    );
    notifyListeners();

    if (framesToEncode.isEmpty) return null;

    // Cross-platform animated GIF encoder using pure Dart `image` package
    try {
      final encoder = img.GifEncoder(delay: 10);
      for (final rawFrame in framesToEncode) {
        final decoded = img.decodeJpg(rawFrame);
        if (decoded != null) {
          final resized = img.copyResize(decoded, width: 320);
          encoder.addFrame(resized);
        }
      }

      final gifBytes = encoder.finish();
      if (gifBytes == null) return null;

      final filename = 'VOZILO_${DateTime.now().millisecondsSinceEpoch}.gif';
      final savedPath = await FileSaver.save(
        bytes: Uint8List.fromList(gifBytes),
        filename: filename,
        mimeType: 'image/gif',
      );
      return savedPath ?? filename;
    } catch (_) {
      return null;
    }
  }

  // --- Ping Monitor ---

  Future<void> _checkPingNow() async {
    if (_isSimulatorMode) {
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.simulated,
        latencyMs: 3,
      );
      notifyListeners();
      return;
    }

    final latency = await _api.measurePing();
    if (latency != null) {
      _telemetry = _telemetry.copyWith(
        connectionStatus: RobotConnectionStatus.connected,
        latencyMs: latency,
        lastError: null,
      );
    } else {
      if (_telemetry.connectionStatus != RobotConnectionStatus.connecting) {
        _telemetry = _telemetry.copyWith(
          connectionStatus: RobotConnectionStatus.disconnected,
          latencyMs: null,
        );
      }
    }
    notifyListeners();
  }

  void _startPingMonitor() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) async {
      await _checkPingNow();
    });
  }

  @override
  void dispose() {
    _commandLoopTimer?.cancel();
    _pingTimer?.cancel();
    _recordingTimer?.cancel();
    _stream.dispose();
    _mock.stopMockStream();
    _api.dispose();
    super.dispose();
  }
}
