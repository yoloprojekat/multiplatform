import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FeaturePill extends StatelessWidget {
  const FeaturePill({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.activeColor = AppColors.aiActive,
    this.inactiveColor = AppColors.surface,
    this.activeTextColor = Colors.black,
    this.isFlashing = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final bool isFlashing;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: hasLabel ? 12 : 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.8)
                  : AppColors.surfaceBorder,
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? activeTextColor : AppColors.cyanAccent,
              ),
              if (hasLabel) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive ? activeTextColor : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
