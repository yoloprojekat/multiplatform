import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/robot_command.dart';

class CompactDPad extends StatelessWidget {
  const CompactDPad({
    super.key,
    required this.currentCommand,
    required this.onCommandChange,
    this.size = 250,
  });

  final RobotCommand currentCommand;
  final ValueChanged<RobotCommand> onCommandChange;
  final double size;

  @override
  Widget build(BuildContext context) {
    final btnSize = size * 0.28;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center decorative target circle
          Container(
            width: size * 0.45,
            height: size * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cyanAccent.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),

          // Center Emergency Stop button
          _buildCenterStopBtn(btnSize * 0.75),

          // Directional Buttons (Cardinal)
          Align(
            alignment: Alignment.topCenter,
            child: _buildDpadButton(
              command: RobotCommand.forward,
              size: btnSize,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildDpadButton(
              command: RobotCommand.backward,
              size: btnSize,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildDpadButton(
              command: RobotCommand.left,
              size: btnSize,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildDpadButton(
              command: RobotCommand.right,
              size: btnSize,
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Rotation Triggers (Corners)
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildRotationButton(
              command: RobotCommand.rotateLeft,
              size: btnSize * 0.82,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _buildRotationButton(
              command: RobotCommand.rotateRight,
              size: btnSize * 0.82,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterStopBtn(double btnSize) {
    final isPressed = currentCommand == RobotCommand.stop;

    return Listener(
      onPointerDown: (_) => onCommandChange(RobotCommand.stop),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: isPressed ? AppColors.recordAlert : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isPressed
                ? AppColors.recordAlert
                : AppColors.surfaceBorderSubtle,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.stop_rounded,
            size: btnSize * 0.55,
            color: isPressed ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDpadButton({
    required RobotCommand command,
    required double size,
    required BorderRadius borderRadius,
  }) {
    final isPressed = currentCommand == command;

    return Listener(
      onPointerDown: (_) => onCommandChange(command),
      onPointerUp: (_) => onCommandChange(RobotCommand.stop),
      onPointerCancel: (_) => onCommandChange(RobotCommand.stop),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPressed ? AppColors.cyanAccent : AppColors.surfaceElevated,
          borderRadius: borderRadius,
          border: Border.all(
            color: isPressed
                ? AppColors.cyanAccent
                : AppColors.surfaceBorder,
            width: isPressed ? 2.0 : 1.0,
          ),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: AppColors.cyanAccent.withValues(alpha: 0.5),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              command.symbol,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w900,
                color: isPressed ? Colors.black : AppColors.cyanAccent,
              ),
            ),
            Text(
              command.keyHint,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isPressed
                    ? Colors.black87
                    : AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationButton({
    required RobotCommand command,
    required double size,
  }) {
    final isPressed = currentCommand == command;

    return Listener(
      onPointerDown: (_) => onCommandChange(command),
      onPointerUp: (_) => onCommandChange(RobotCommand.stop),
      onPointerCancel: (_) => onCommandChange(RobotCommand.stop),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPressed ? AppColors.neonBlue : AppColors.surfaceElevated,
          border: Border.all(
            color: isPressed ? AppColors.cyanAccent : AppColors.surfaceBorder,
            width: isPressed ? 2.0 : 1.0,
          ),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: AppColors.neonBlue.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              command.icon,
              size: size * 0.44,
              color: isPressed ? Colors.white : AppColors.cyanAccent,
            ),
            Text(
              command.keyHint,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isPressed ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
