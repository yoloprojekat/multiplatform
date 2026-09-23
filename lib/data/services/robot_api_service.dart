import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/robot_constants.dart';

class RobotApiService {
  RobotApiService({http.Client? client}) : _client = client ?? http.Client();

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
      ).timeout(const Duration(milliseconds: 2000));

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
      ).timeout(const Duration(milliseconds: 2000));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Measures roundtrip ping latency in milliseconds
  Future<int?> measurePing() async {
    try {
      final stopwatch = Stopwatch()..start();
      final uri = Uri.parse('$_baseUrl${RobotConstants.controlPath}');
      // Send a benign check or stop ping
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cmd': 'stop'}),
      ).timeout(const Duration(milliseconds: 1500));
      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
