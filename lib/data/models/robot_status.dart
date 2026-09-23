import 'robot_command.dart';

enum RobotConnectionStatus {
  disconnected,
  connecting,
  connected,
  simulated,
}

class RobotTelemetry {
  const RobotTelemetry({
    this.connectionStatus = RobotConnectionStatus.disconnected,
    this.latencyMs,
    this.streamFps = 0.0,
    this.isDetectionOn = false,
    this.isFollowOn = false,
    this.isOcrRunning = false,
    this.isAutopilotRunning = false,
    this.ocrDetectedText = '',
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.recordedFramesCount = 0,
    this.isCamOn = false,
    this.currentCommand = RobotCommand.stop,
    this.lastError,
  });

  final RobotConnectionStatus connectionStatus;
  final int? latencyMs;
  final double streamFps;
  final bool isDetectionOn;
  final bool isFollowOn;
  final bool isOcrRunning;
  final bool isAutopilotRunning;
  final String ocrDetectedText;
  final bool isRecording;
  final Duration recordingDuration;
  final int recordedFramesCount;
  final bool isCamOn;
  final RobotCommand currentCommand;
  final String? lastError;

  bool get isConnected =>
      connectionStatus == RobotConnectionStatus.connected ||
      connectionStatus == RobotConnectionStatus.simulated;

  RobotTelemetry copyWith({
    RobotConnectionStatus? connectionStatus,
    int? latencyMs,
    double? streamFps,
    bool? isDetectionOn,
    bool? isFollowOn,
    bool? isOcrRunning,
    bool? isAutopilotRunning,
    String? ocrDetectedText,
    bool? isRecording,
    Duration? recordingDuration,
    int? recordedFramesCount,
    bool? isCamOn,
    RobotCommand? currentCommand,
    String? lastError,
  }) {
    return RobotTelemetry(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      latencyMs: latencyMs ?? this.latencyMs,
      streamFps: streamFps ?? this.streamFps,
      isDetectionOn: isDetectionOn ?? this.isDetectionOn,
      isFollowOn: isFollowOn ?? this.isFollowOn,
      isOcrRunning: isOcrRunning ?? this.isOcrRunning,
      isAutopilotRunning: isAutopilotRunning ?? this.isAutopilotRunning,
      ocrDetectedText: ocrDetectedText ?? this.ocrDetectedText,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordedFramesCount: recordedFramesCount ?? this.recordedFramesCount,
      isCamOn: isCamOn ?? this.isCamOn,
      currentCommand: currentCommand ?? this.currentCommand,
      lastError: lastError,
    );
  }
}
