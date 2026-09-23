import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/robot_constants.dart';
import '../../core/utils/http_client_factory.dart';
import '../../core/utils/mjpeg_decoder.dart';

typedef OnFrameCallback = void Function(Uint8List frameBytes, double fps);
typedef OnStreamErrorCallback = void Function(String error);
typedef OnStreamConnectedCallback = void Function();

class MjpegStreamService {
  MjpegStreamService({http.Client? client})
      : _client = client ??
            createHttpClient(
              timeout: const Duration(seconds: 3),
              idleTimeout: const Duration(days: 365),
            );

  final http.Client _client;
  final MjpegDecoder _decoder = MjpegDecoder();

  StreamSubscription<List<int>>? _subscription;
  Timer? _reconnectTimer;
  bool _isActive = false;

  int _fpsFrameCount = 0;
  int _fpsWindowStart = 0;
  double _currentFps = 0.0;

  bool get isActive => _isActive;

  Future<void> startStream({
    required String baseUrl,
    required OnFrameCallback onFrame,
    required OnStreamConnectedCallback onConnected,
    required OnStreamErrorCallback onError,
  }) async {
    await stopStream();
    _isActive = true;
    _decoder.reset();
    _fpsFrameCount = 0;
    _fpsWindowStart = DateTime.now().millisecondsSinceEpoch;

    await _connect(
      baseUrl: baseUrl,
      onFrame: onFrame,
      onConnected: onConnected,
      onError: onError,
      isReconnect: false,
    );
  }

  Future<void> _connect({
    required String baseUrl,
    required OnFrameCallback onFrame,
    required OnStreamConnectedCallback onConnected,
    required OnStreamErrorCallback onError,
    required bool isReconnect,
  }) async {
    if (!_isActive) return;

    try {
      final uri = Uri.parse('$baseUrl${RobotConstants.videoFeedPath}');
      final request = http.Request('GET', uri);
      request.headers['Connection'] = 'keep-alive';
      request.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
      request.headers['Pragma'] = 'no-cache';
      request.headers['Accept'] = 'multipart/x-mixed-replace, image/jpeg, */*';

      final response = await _client.send(request).timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => throw TimeoutException('Video stream connection timed out'),
      );

      if (!_isActive) return;

      if (response.statusCode != 200) {
        if (!isReconnect) {
          _isActive = false;
          onError('Stream HTTP error ${response.statusCode}');
        } else {
          _scheduleReconnect(baseUrl, onFrame, onConnected, onError);
        }
        return;
      }

      onConnected();

      await _subscription?.cancel();
      _subscription = response.stream.listen(
        (chunk) {
          if (!_isActive) return;

          final frames = _decoder.processChunk(Uint8List.fromList(chunk));
          final now = DateTime.now().millisecondsSinceEpoch;

          if (frames.isNotEmpty) {
            _fpsFrameCount += frames.length;

            final elapsedWindow = now - _fpsWindowStart;
            if (elapsedWindow >= 1000) {
              _currentFps = (_fpsFrameCount * 1000.0) / elapsedWindow;
              _fpsFrameCount = 0;
              _fpsWindowStart = now;
            }

            // Immediately deliver the freshest frame (ultra-low latency, maximum FPS)
            onFrame(frames.last, _currentFps);
          }
        },
        onError: (err) {
          if (_isActive) {
            // Seamless auto-reconnect (bypasses 5-minute server or socket timeout limits)
            _scheduleReconnect(baseUrl, onFrame, onConnected, onError);
          }
        },
        onDone: () {
          if (_isActive) {
            // Stream ended by server (e.g. 5-minute timeout): auto-reconnect instantly
            _scheduleReconnect(baseUrl, onFrame, onConnected, onError);
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!_isActive) return;
      if (!isReconnect) {
        _isActive = false;
        onError('Connection error: $e');
      } else {
        _scheduleReconnect(baseUrl, onFrame, onConnected, onError);
      }
    }
  }

  void _scheduleReconnect(
    String baseUrl,
    OnFrameCallback onFrame,
    OnStreamConnectedCallback onConnected,
    OnStreamErrorCallback onError,
  ) {
    _reconnectTimer?.cancel();
    if (!_isActive) return;

    _reconnectTimer = Timer(RobotConstants.streamReconnectDelay, () {
      if (_isActive) {
        _connect(
          baseUrl: baseUrl,
          onFrame: onFrame,
          onConnected: onConnected,
          onError: onError,
          isReconnect: true,
        );
      }
    });
  }

  Future<void> stopStream() async {
    _isActive = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    _decoder.reset();
    _currentFps = 0.0;
  }

  void dispose() {
    stopStream();
    _client.close();
  }
}
