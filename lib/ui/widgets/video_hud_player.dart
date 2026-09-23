import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class VideoHudPlayer extends StatelessWidget {
  const VideoHudPlayer({
    super.key,
    required this.isCamOn,
    required this.frame,
    required this.streamFps,
    required this.latencyMs,
    required this.isRecording,
    required this.recordingDuration,
    required this.isOcrRunning,
    required this.isAutopilotRunning,
    required this.ocrOverlayText,
    required this.onToggleCamera,
    required this.onSnapshot,
    this.height = 280,
  });

  final bool isCamOn;
  final Uint8List? frame;
  final double streamFps;
  final int? latencyMs;
  final bool isRecording;
  final Duration recordingDuration;
  final bool isOcrRunning;
  final bool isAutopilotRunning;
  final String ocrOverlayText;
  final VoidCallback onToggleCamera;
  final VoidCallback onSnapshot;
  final double height;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCamOn
              ? AppColors.cyanAccent.withValues(alpha: 0.4)
              : AppColors.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCamOn ? AppColors.cyanAccent : Colors.black)
                .withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Frame or Standby Radar
            if (isCamOn && frame != null)
              Image.memory(
                frame!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            else if (isCamOn && frame == null)
              _buildConnectingState()
            else
              _buildStandbyState(),

            // Cyberpunk HUD Corner Brackets
            CustomPaint(
              painter: _HudCornerPainter(
                color: isCamOn ? AppColors.cyanAccent : AppColors.textDisabled,
              ),
            ),

            // Top Overlay Bar: LIVE / REC, FPS & Ping, Snapshot
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Tags
                  Row(
                    children: [
                      if (isCamOn) ...[
                        _buildStatusBadge(
                          color: AppColors.statusOnline,
                          label: 'LIVE',
                          showDot: true,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isRecording) ...[
                        _buildStatusBadge(
                          color: AppColors.recordAlert,
                          label: 'REC ${_formatDuration(recordingDuration)}',
                          showDot: true,
                        ),
                      ],
                    ],
                  ),

                  // Telemetry Readouts & Snapshot Button
                  Row(
                    children: [
                      if (isCamOn && streamFps > 0)
                        _buildTelemetryChip(
                          '${streamFps.toStringAsFixed(1)} FPS',
                          Icons.speed_rounded,
                        ),
                      if (latencyMs != null) ...[
                        const SizedBox(width: 6),
                        _buildTelemetryChip(
                          '$latencyMs ms',
                          Icons.network_check_rounded,
                        ),
                      ],
                      if (isCamOn) ...[
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: onSnapshot,
                          icon: const Icon(Icons.camera_alt_rounded, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppColors.surfaceElevated.withValues(alpha: 0.8),
                            foregroundColor: AppColors.cyanAccent,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(36, 36),
                          ),
                          tooltip: 'Capture Snapshot',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Bottom-Left Overlay: OCR Detected Text Banner
            if (isOcrRunning && ocrOverlayText.isNotEmpty)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAutopilotRunning
                          ? AppColors.statusOnline
                          : AppColors.cyanAccent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isAutopilotRunning
                                ? AppColors.statusOnline
                                : AppColors.cyanAccent)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAutopilotRunning
                            ? Icons.smart_toy_rounded
                            : Icons.text_fields_rounded,
                        size: 16,
                        color: isAutopilotRunning
                            ? AppColors.statusOnline
                            : AppColors.cyanAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ocrOverlayText.toUpperCase(),
                        style: TextStyle(
                          color: isAutopilotRunning
                              ? AppColors.statusOnline
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom-Right Overlay: Camera Power Button
            Positioned(
              bottom: 12,
              right: 12,
              child: IconButton.filled(
                onPressed: onToggleCamera,
                icon: Icon(
                  isCamOn
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isCamOn
                      ? AppColors.cyanAccent
                      : AppColors.surfaceElevated.withValues(alpha: 0.8),
                  foregroundColor: isCamOn ? Colors.black : AppColors.cyanAccent,
                ),
                tooltip: isCamOn ? 'Stop Camera' : 'Start Camera',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.cyanAccent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'CONNECTING TO MJPEG FEED...',
            style: TextStyle(
              color: AppColors.cyanAccent.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandbyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cyanAccent.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.videocam_off_outlined,
              size: 34,
              color: AppColors.cyanAccent.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'STREAM STANDBY',
            style: TextStyle(
              color: AppColors.cyanAccent.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'CAMERA FEED OFFLINE',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required Color color,
    required String label,
    required bool showDot,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
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
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceBorderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.cyanAccent),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HudCornerPainter extends CustomPainter {
  _HudCornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 16.0;
    const padding = 6.0;

    // Top-Left
    canvas.drawLine(const Offset(padding, padding + cornerLength),
        const Offset(padding, padding), paint);
    canvas.drawLine(const Offset(padding, padding),
        const Offset(padding + cornerLength, padding), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width - padding - cornerLength, padding),
        Offset(size.width - padding, padding), paint);
    canvas.drawLine(Offset(size.width - padding, padding),
        Offset(size.width - padding, padding + cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(padding, size.height - padding - cornerLength),
        Offset(padding, size.height - padding), paint);
    canvas.drawLine(Offset(padding, size.height - padding),
        Offset(padding + cornerLength, size.height - padding), paint);

    // Bottom-Right
    canvas.drawLine(
        Offset(size.width - padding - cornerLength, size.height - padding),
        Offset(size.width - padding, size.height - padding),
        paint);
    canvas.drawLine(
        Offset(size.width - padding, size.height - padding - cornerLength),
        Offset(size.width - padding, size.height - padding),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
