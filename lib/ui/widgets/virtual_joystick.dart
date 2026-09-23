import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({
    super.key,
    required this.onPan,
    this.size = 210,
    this.handleSize = 64,
  });

  final void Function(double offX, double offY, double radius) onPan;
  final double size;
  final double handleSize;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick>
    with SingleTickerProviderStateMixin {
  Offset _handleOffset = Offset.zero;
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _handleOffset = _springAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanUpdate(Offset localPosition) {
    _springController.stop();
    final center = Offset(widget.size / 2, widget.size / 2);
    final rawDelta = localPosition - center;

    final maxDistance = (widget.size - widget.handleSize) / 2;
    final distance = rawDelta.distance;

    Offset clampedOffset;
    if (distance > maxDistance) {
      final angle = atan2(rawDelta.dy, rawDelta.dx);
      clampedOffset = Offset(
        cos(angle) * maxDistance,
        sin(angle) * maxDistance,
      );
    } else {
      clampedOffset = rawDelta;
    }

    setState(() {
      _handleOffset = clampedOffset;
    });

    widget.onPan(_handleOffset.dx, _handleOffset.dy, maxDistance);
  }

  void _onPanEnd() {
    final startOffset = _handleOffset;
    _springAnimation = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutBack,
    ));

    _springController.forward(from: 0);
    widget.onPan(0, 0, (widget.size - widget.handleSize) / 2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _onPanUpdate(details.localPosition),
      onPanUpdate: (details) => _onPanUpdate(details.localPosition),
      onPanEnd: (_) => _onPanEnd(),
      onPanCancel: () => _onPanEnd(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.joystickBase,
          border: Border.all(
            color: AppColors.cyanAccent.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Directional crosshair lines
            Container(
              width: widget.size * 0.8,
              height: 1,
              color: AppColors.cyanAccent.withValues(alpha: 0.15),
            ),
            Container(
              width: 1,
              height: widget.size * 0.8,
              color: AppColors.cyanAccent.withValues(alpha: 0.15),
            ),
            // Inner deadzone ring
            Container(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),

            // Movable Thumbstick Knob
            Transform.translate(
              offset: _handleOffset,
              child: Container(
                width: widget.handleSize,
                height: widget.handleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF29B6F6),
                      Color(0xFF0288D1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanAccent.withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.control_camera_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
