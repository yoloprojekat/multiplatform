import 'package:flutter/material.dart';
import '../../controllers/robot_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/robot_command.dart';
import '../../data/models/robot_status.dart';
import '../widgets/compact_dpad.dart';
import '../widgets/connection_settings_dialog.dart';
import '../widgets/feature_pill.dart';
import '../widgets/keyboard_shortcuts_listener.dart';
import '../widgets/media_preview_dialog.dart';
import '../widgets/video_hud_player.dart';
import '../widgets/virtual_joystick.dart';

class CockpitScreen extends StatelessWidget {
  const CockpitScreen({super.key, required this.controller});

  final RobotController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final telemetry = controller.telemetry;

        return KeyboardShortcutsListener(
          onCommand: (cmd) => controller.setCommand(cmd),
          onStop: () => controller.stopMoving(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, telemetry),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return _buildDesktopCockpit(context, telemetry, constraints);
                  } else {
                    return _buildMobileCockpit(context, telemetry, constraints);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, RobotTelemetry telemetry) {
    return AppBar(
      backgroundColor: AppColors.backgroundSecondary,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          // Logo Icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyanAccent.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.cyanAccent, width: 1.5),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.cyanAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOLO VOZILO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.cyanAccent,
                ),
              ),
              _buildConnectionBadge(telemetry.connectionStatus),
            ],
          ),
        ],
      ),
      actions: [
        // Camera Snapshot Button (Quick Access)
        if (telemetry.isCamOn)
          IconButton(
            onPressed: () => _handleSnapshot(context),
            icon: const Icon(Icons.camera_alt_rounded),
            color: AppColors.cyanAccent,
            tooltip: 'Capture Photo',
          ),

        // Camera Feed Toggle
        IconButton(
          onPressed: () => controller.toggleCamera(),
          icon: Icon(
            telemetry.isCamOn ? Icons.videocam : Icons.videocam_off,
            color: telemetry.isCamOn ? AppColors.cyanAccent : AppColors.textDisabled,
          ),
          tooltip: telemetry.isCamOn ? 'Power Off Camera' : 'Power On Camera',
        ),

        // Settings Dialog
        IconButton(
          onPressed: () => _showSettingsDialog(context),
          icon: const Icon(Icons.tune_rounded),
          color: AppColors.textPrimary,
          tooltip: 'System Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildConnectionBadge(RobotConnectionStatus status) {
    Color color;
    String label;

    switch (status) {
      case RobotConnectionStatus.connected:
        color = AppColors.statusOnline;
        label = 'ONLINE';
        break;
      case RobotConnectionStatus.simulated:
        color = AppColors.statusSimulated;
        label = 'SIMULATOR';
        break;
      case RobotConnectionStatus.connecting:
        color = AppColors.statusWarning;
        label = 'CONNECTING';
        break;
      case RobotConnectionStatus.disconnected:
        color = AppColors.statusOffline;
        label = 'OFFLINE';
        break;
    }

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.8),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  // --- Wide / Desktop Layout ---

  Widget _buildDesktopCockpit(
    BuildContext context,
    RobotTelemetry telemetry,
    BoxConstraints constraints,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Video HUD & AI Feature Row
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: VideoHudPlayer(
                    height: double.infinity,
                    isCamOn: telemetry.isCamOn,
                    frame: controller.currentFrame,
                    streamFps: telemetry.streamFps,
                    latencyMs: telemetry.latencyMs,
                    isRecording: telemetry.isRecording,
                    recordingDuration: telemetry.recordingDuration,
                    isOcrRunning: telemetry.isOcrRunning,
                    isAutopilotRunning: telemetry.isAutopilotRunning,
                    ocrOverlayText: telemetry.ocrDetectedText,
                    onToggleCamera: () => controller.toggleCamera(),
                    onSnapshot: () => _handleSnapshot(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionPillsRow(context, telemetry),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right Side: Control Center
          SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildControlsCard(telemetry),
                  const SizedBox(height: 16),
                  _buildKeyboardGuideCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile / Narrow Layout ---

  Widget _buildMobileCockpit(
    BuildContext context,
    RobotTelemetry telemetry,
    BoxConstraints constraints,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Video Section
          VideoHudPlayer(
            height: 230,
            isCamOn: telemetry.isCamOn,
            frame: controller.currentFrame,
            streamFps: telemetry.streamFps,
            latencyMs: telemetry.latencyMs,
            isRecording: telemetry.isRecording,
            recordingDuration: telemetry.recordingDuration,
            isOcrRunning: telemetry.isOcrRunning,
            isAutopilotRunning: telemetry.isAutopilotRunning,
            ocrOverlayText: telemetry.ocrDetectedText,
            onToggleCamera: () => controller.toggleCamera(),
            onSnapshot: () => _handleSnapshot(context),
          ),

          const SizedBox(height: 14),

          // Action Pills
          _buildActionPillsRow(context, telemetry),

          const SizedBox(height: 16),

          // Driving Controller Area
          _buildControlsCard(telemetry),
        ],
      ),
    );
  }

  // --- Control Cards & Buttons ---

  Widget _buildActionPillsRow(BuildContext context, RobotTelemetry telemetry) {
    return Column(
      children: [
        // Row 1: Vision AI, Recording, OCR Toggle
        Row(
          children: [
            Expanded(
              child: FeaturePill(
                label: telemetry.isDetectionOn ? 'VISION ON' : 'VISION OFF',
                icon: Icons.visibility_rounded,
                isActive: telemetry.isDetectionOn,
                activeColor: AppColors.aiActive,
                activeTextColor: Colors.black,
                onTap: () => controller.toggleDetection(!telemetry.isDetectionOn),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FeaturePill(
                label: telemetry.isRecording ? 'STOP REC' : 'RECORD',
                icon: telemetry.isRecording
                    ? Icons.stop_rounded
                    : Icons.fiber_manual_record_rounded,
                isActive: telemetry.isRecording,
                activeColor: AppColors.recordAlert,
                activeTextColor: Colors.white,
                onTap: () => _handleRecordToggle(context),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              child: FeaturePill(
                label: '',
                icon: Icons.text_fields_rounded,
                isActive: telemetry.isOcrRunning,
                activeColor: AppColors.cyanAccent,
                activeTextColor: Colors.black,
                onTap: () => controller.toggleOcr(),
              ),
            ),
          ],
        ),

        // Row 2: Follow AI & OCR AutoPilot (conditional visibility)
        if (telemetry.isDetectionOn || telemetry.isOcrRunning) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (telemetry.isDetectionOn)
                Expanded(
                  child: FeaturePill(
                    label: telemetry.isFollowOn ? 'FOLLOWING' : 'FOLLOW AI',
                    icon: Icons.directions_run_rounded,
                    isActive: telemetry.isFollowOn,
                    activeColor: AppColors.statusOnline,
                    activeTextColor: Colors.black,
                    onTap: () => controller.toggleFollow(!telemetry.isFollowOn),
                  ),
                ),
              if (telemetry.isDetectionOn && telemetry.isOcrRunning)
                const SizedBox(width: 8),
              if (telemetry.isOcrRunning)
                Expanded(
                  child: FeaturePill(
                    label: telemetry.isAutopilotRunning ? 'AUTO ON' : 'AUTO OFF',
                    icon: Icons.smart_toy_rounded,
                    isActive: telemetry.isAutopilotRunning,
                    activeColor: AppColors.statusOnline,
                    activeTextColor: Colors.black,
                    onTap: () => controller.toggleAutopilot(),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildControlsCard(RobotTelemetry telemetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorderSubtle),
      ),
      child: Column(
        children: [
          // Switcher Bar: D-Pad vs Joystick
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.useJoystick
                          ? Icons.sports_esports_rounded
                          : Icons.gamepad_rounded,
                      size: 16,
                      color: AppColors.cyanAccent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        controller.useJoystick ? 'VIRTUAL JOYSTICK' : 'COMPACT D-PAD',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: controller.useJoystick,
                onChanged: (val) => controller.useJoystick = val,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active Controller Widget
          Center(
            child: controller.useJoystick
                ? VirtualJoystick(
                    onPan: (offX, offY, radius) =>
                        controller.handleJoystick(offX, offY, radius),
                  )
                : CompactDPad(
                    currentCommand: telemetry.currentCommand,
                    onCommandChange: (cmd) => controller.setCommand(cmd),
                  ),
          ),

          const SizedBox(height: 12),

          // Command Feedback Readout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceBorderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  telemetry.currentCommand.icon,
                  size: 14,
                  color: telemetry.currentCommand == RobotCommand.stop
                      ? AppColors.textSecondary
                      : AppColors.cyanAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CMD: ${telemetry.currentCommand.label}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: telemetry.currentCommand == RobotCommand.stop
                        ? AppColors.textSecondary
                        : AppColors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.keyboard_rounded, size: 16, color: AppColors.cyanAccent),
              SizedBox(width: 8),
              Text(
                'KEYBOARD SHORTCUTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildShortcutRow('W / ↑', 'Forward (napred)'),
          _buildShortcutRow('S / ↓', 'Backward (nazad)'),
          _buildShortcutRow('A / ←', 'Turn Left (levo)'),
          _buildShortcutRow('D / →', 'Turn Right (desno)'),
          _buildShortcutRow('Q / E', 'Rotate Left / Right'),
          _buildShortcutRow('Space', 'Emergency Stop'),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String key, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.surfaceBorderSubtle),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.cyanAccent,
              ),
            ),
          ),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // --- Handlers & Dialogs ---

  Future<void> _handleSnapshot(BuildContext context) async {
    final pathOrName = await controller.captureSnapshot();
    if (pathOrName != null && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => MediaPreviewDialog(
          title: 'Photo Captured',
          message: 'Frame saved successfully to gallery / device downloads.',
          filePathOrName: pathOrName,
          isImage: true,
        ),
      );
    }
  }

  Future<void> _handleRecordToggle(BuildContext context) async {
    if (!controller.telemetry.isRecording) {
      await controller.startRecording();
    } else {
      final savedClip = await controller.stopRecording();
      if (savedClip != null && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => MediaPreviewDialog(
            title: 'Video Recording Saved',
            message: 'Recorded frames successfully rendered and saved.',
            filePathOrName: savedClip,
            isImage: false,
          ),
        );
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConnectionSettingsDialog(
        currentHost: controller.hostUrl,
        isSimulatorMode: controller.isSimulatorMode,
        connectionStatus: controller.telemetry.connectionStatus,
        latencyMs: controller.telemetry.latencyMs,
        onSaveHost: (newHost) => controller.updateHostUrl(newHost),
        onToggleSimulator: (val) => controller.setSimulatorMode(val),
        onInjectOcrText: (text) => controller.injectOcrResult(text),
        onFastScan: () => controller.fastScanAndConnect(),
      ),
    );
  }
}
