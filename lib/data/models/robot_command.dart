import 'package:flutter/material.dart';
import '../../core/constants/robot_constants.dart';

enum RobotCommand {
  stop(
    code: RobotConstants.cmdStop,
    label: 'STOP',
    symbol: '■',
    icon: Icons.stop_rounded,
    keyHint: 'Space',
  ),
  forward(
    code: RobotConstants.cmdForward,
    label: 'FORWARD',
    symbol: '▲',
    icon: Icons.arrow_upward_rounded,
    keyHint: 'W / ↑',
  ),
  backward(
    code: RobotConstants.cmdBackward,
    label: 'BACKWARD',
    symbol: '▼',
    icon: Icons.arrow_downward_rounded,
    keyHint: 'S / ↓',
  ),
  left(
    code: RobotConstants.cmdLeft,
    label: 'LEFT',
    symbol: '◀',
    icon: Icons.arrow_back_rounded,
    keyHint: 'A / ←',
  ),
  right(
    code: RobotConstants.cmdRight,
    label: 'RIGHT',
    symbol: '▶',
    icon: Icons.arrow_forward_rounded,
    keyHint: 'D / →',
  ),
  rotateLeft(
    code: RobotConstants.cmdRotateLeft,
    label: 'ROTATE L',
    symbol: '↺',
    icon: Icons.rotate_left_rounded,
    keyHint: 'Q',
  ),
  rotateRight(
    code: RobotConstants.cmdRotateRight,
    label: 'ROTATE R',
    symbol: '↻',
    icon: Icons.rotate_right_rounded,
    keyHint: 'E',
  );

  const RobotCommand({
    required this.code,
    required this.label,
    required this.symbol,
    required this.icon,
    required this.keyHint,
  });

  final String code;
  final String label;
  final String symbol;
  final IconData icon;
  final String keyHint;

  static RobotCommand fromCode(String code) {
    return RobotCommand.values.firstWhere(
      (cmd) => cmd.code == code,
      orElse: () => RobotCommand.stop,
    );
  }
}
