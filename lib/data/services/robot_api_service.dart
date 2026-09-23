import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/robot_constants.dart';
import '../../core/utils/http_client_factory.dart';

class RobotApiService {
  RobotApiService({http.Client? client})
      : _client = client ?? createHttpClient(timeout: const Duration(milliseconds: 2500));

  final http.Client _client;
  String _baseUrl = RobotConstants.defaultHost;

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newUrl) {
    var sanitized = newUrl.trim();
    if (sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
      sanitized = 'http://$sanitized';
    }
    _baseUrl = sanitized;
  }

  /// Sends a movement command payload `{"cmd": "<command>"}` to `/control`
  Future<bool> sendCommand(String cmd) async {
    try {
      final uri = Uri.parse('$_baseUrl${RobotConstants.controlPath}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cmd': cmd}),
      ).timeout(const Duration(milliseconds: 1200));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Toggles remote YOLO Vision detection on Raspberry Pi
  Future<bool> toggleDetection(bool enable) async {
    try {
      final uri = Uri.parse('$_baseUrl${RobotConstants.toggleDetectionPath}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enable': enable}),
      ).timeout(const Duration(milliseconds: 1800));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Toggles remote Autonomous Person Follow on Raspberry Pi
  Future<bool> toggleFollow(bool enable) async {
    try {
      final uri = Uri.parse('$_baseUrl${RobotConstants.toggleFollowPath}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'enable': enable}),
      ).timeout(const Duration(milliseconds: 1800));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Measures roundtrip ping latency in milliseconds for current base URL
  Future<int?> measurePing({Duration timeout = const Duration(milliseconds: 1200)}) async {
    return measurePingForHost(_baseUrl, timeout: timeout);
  }

  /// Measures roundtrip ping latency for any host candidate
  Future<int?> measurePingForHost(
    String hostUrl, {
    Duration timeout = const Duration(milliseconds: 1200),
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      var cleanUrl = hostUrl.trim();
      if (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'http://$cleanUrl';
      }

      final uri = Uri.parse('$cleanUrl${RobotConstants.controlPath}');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cmd': 'stop'}),
      ).timeout(timeout);
      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fast parallel discovery: tests multiple candidate addresses concurrently
  /// and returns the fastest responding host and its latency in <= 2 seconds.
  Future<({String host, int latencyMs})?> fastProbeCandidates(
    List<String> candidates, {
    Duration timeout = const Duration(milliseconds: 1800),
  }) async {
    final completer = Completer<({String host, int latencyMs})?>();
    int pendingCount = candidates.length;

    if (candidates.isEmpty) return null;

    for (final candidate in candidates) {
      unawaited(
        measurePingForHost(candidate, timeout: timeout).then((latency) {
          if (completer.isCompleted) return;
          if (latency != null) {
            completer.complete((host: candidate, latencyMs: latency));
          } else {
            pendingCount--;
            if (pendingCount <= 0 && !completer.isCompleted) {
              completer.complete(null);
            }
          }
        }).catchError((_) {
          if (completer.isCompleted) return;
          pendingCount--;
          if (pendingCount <= 0 && !completer.isCompleted) {
            completer.complete(null);
          }
        }),
      );
    }

    // Backup hard timeout
    Future.delayed(timeout + const Duration(milliseconds: 200), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  void dispose() {
    _client.close();
  }
}
