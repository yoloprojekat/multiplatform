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
      : _client = client ?? createHttpClient(timeout: const Duration(seconds: 3));

  final http.Client _client;
  final MjpegDecoder _decoder = MjpegDecoder();

  StreamSubscription<List<int>>? _subscription;
  bool _isActive = false;

  int _lastFrameTimestamp = 0;
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

    try {
      final uri = Uri.parse('$baseUrl${RobotConstants.videoFeedPath}');
      final request = http.Request('GET', uri);
      final response = await _client.send(request).timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => throw TimeoutException('Connection to video stream timed out (3.5s)'),
      );

      if (!_isActive) return;

      if (response.statusCode != 200) {
        _isActive = false;
        onError('Stream HTTP error ${response.statusCode}');
        return;
      }

      onConnected();

      _subscription = response.stream.listen(
        (chunk) {
          if (!_isActive) return;

          final frames = _decoder.processChunk(Uint8List.fromList(chunk));
          final now = DateTime.now().millisecondsSinceEpoch;

          for (final frame in frames) {
            // Frame throttle for battery/performance
            if (now - _lastFrameTimestamp >= RobotConstants.streamThrottleInterval.inMilliseconds) {
              _lastFrameTimestamp = now;
              _fpsFrameCount++;

              // Calculate rolling FPS every second
              final elapsedWindow = now - _fpsWindowStart;
              if (elapsedWindow >= 1000) {
                _currentFps = (_fpsFrameCount * 1000.0) / elapsedWindow;
                _fpsFrameCount = 0;
                _fpsWindowStart = now;
              }

              onFrame(frame, _currentFps);
            }
          }
        },
        onError: (err) {
          _isActive = false;
          onError('Stream interrupted: $err');
        },
        onDone: () {
          if (_isActive) {
            _isActive = false;
            onError('Video feed disconnected');
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      _isActive = false;
      onError('Connection error: $e');
    }
  }

  Future<void> stopStream() async {
    _isActive = false;
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
