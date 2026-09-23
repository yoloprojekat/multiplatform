import 'package:flutter/material.dart';

/// App color palette for the YOLO Vozilo Cockpit UI.
/// Designed for a futuristic, high-contrast, cyberpunk telemetry aesthetic.
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF090C12);
  static const Color backgroundSecondary = Color(0xFF0F141F);
  
  // Surfaces & Cards
  static const Color surface = Color(0xFF141B29);
  static const Color surfaceElevated = Color(0xFF1B2436);
  static const Color surfaceBorder = Color(0x3300E5FF);
  static const Color surfaceBorderSubtle = Color(0x1A00E5FF);

  // Accents & Brand
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color electricPurple = Color(0xFF7C4DFF);

  // Status Indicators
  static const Color statusOnline = Color(0xFF00E676);
  static const Color statusOffline = Color(0xFFFF1744);
  static const Color statusWarning = Color(0xFFFFAB00);
  static const Color statusSimulated = Color(0xFF00B0FF);

  // Controls & Actions
  static const Color recordAlert = Color(0xFFFF1744);
  static const Color aiActive = Color(0xFF00E676);
  static const Color aiInactive = Color(0xFF37474F);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F9BB3);
  static const Color textDisabled = Color(0xFF4A5568);

  // Joystick & D-Pad
  static const Color joystickBase = Color(0xFF141C2B);
  static const Color joystickThumb = Color(0xFF00E5FF);
  static const Color dpadButtonIdle = Color(0xFF141B29);
  static const Color dpadButtonPressed = Color(0xFF00E5FF);

  // Stream Overlays
  static const Color hudOverlay = Color(0x99000000);
  static const Color hudGrid = Color(0x0D00E5FF);
}
