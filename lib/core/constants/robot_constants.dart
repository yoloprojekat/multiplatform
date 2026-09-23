class RobotConstants {
  // Default network configuration
  static const String defaultHost = 'http://pametno-vozilo.local:1607';
  static const String controlPath = '/control';
  static const String videoFeedPath = '/video_feed';
  static const String toggleDetectionPath = '/toggle_detection';
  static const String toggleFollowPath = '/toggle_follow';

  // Commands
  static const String cmdStop = 'stop';
  static const String cmdForward = 'napred';
  static const String cmdBackward = 'nazad';
  static const String cmdLeft = 'levo';
  static const String cmdRight = 'desno';
  static const String cmdRotateLeft = 'rot_levo';
  static const String cmdRotateRight = 'rot_desno';

  // Timing
  static const Duration commandLoopInterval = Duration(milliseconds: 50);
  static const Duration commandKeepAliveInterval = Duration(milliseconds: 1500);
  static const Duration autopilotDriveDuration = Duration(milliseconds: 1500);
  static const Duration autopilotPauseDuration = Duration(milliseconds: 500);
  static const Duration streamThrottleInterval = Duration.zero;
  static const Duration streamReconnectDelay = Duration(milliseconds: 100);
  static const Duration pingCheckInterval = Duration(seconds: 4);

  // Joystick Thresholds
  static const double joystickDeadzone = 30.0;
  static const double joystickMaxRadius = 90.0;

  // OCR Keywords
  static const Map<String, String> ocrKeywordCommands = {
    'rotate': cmdRotateRight,
    'left': cmdLeft,
    'right': cmdRight,
    'back': cmdBackward,
    'forward': cmdForward,
  };
}
