import 'package:flutter/material.dart';
import '../../core/constants/robot_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/robot_status.dart';

class ConnectionSettingsDialog extends StatefulWidget {
  const ConnectionSettingsDialog({
    super.key,
    required this.currentHost,
    required this.isSimulatorMode,
    required this.connectionStatus,
    required this.latencyMs,
    required this.onSaveHost,
    required this.onToggleSimulator,
    required this.onInjectOcrText,
  });

  final String currentHost;
  final bool isSimulatorMode;
  final RobotConnectionStatus connectionStatus;
  final int? latencyMs;
  final ValueChanged<String> onSaveHost;
  final ValueChanged<bool> onToggleSimulator;
  final ValueChanged<String> onInjectOcrText;

  @override
  State<ConnectionSettingsDialog> createState() =>
      _ConnectionSettingsDialogState();
}

class _ConnectionSettingsDialogState extends State<ConnectionSettingsDialog> {
  late TextEditingController _hostController;
  late TextEditingController _ocrTestController;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.currentHost);
    _ocrTestController = TextEditingController();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _ocrTestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppColors.cyanAccent, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'SYSTEM & TELEMETRY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(color: AppColors.surfaceBorderSubtle, height: 24),

              // Mock Robot Simulator Switch
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSimulatorMode
                        ? AppColors.statusSimulated.withValues(alpha: 0.5)
                        : AppColors.surfaceBorderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isSimulatorMode
                            ? AppColors.statusSimulated.withValues(alpha: 0.2)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: widget.isSimulatorMode
                            ? AppColors.statusSimulated
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mock Robot Simulator',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.isSimulatorMode
                                ? 'Simulating feed & telemetry locally'
                                : 'Connects to physical Raspberry Pi',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: widget.isSimulatorMode,
                      onChanged: (val) {
                        widget.onToggleSimulator(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Server URL Field
              const Text(
                'ROBOT SERVER URL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hostController,
                style: const TextStyle(
                  color: AppColors.cyanAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  prefixIcon: const Icon(Icons.link_rounded, color: AppColors.cyanAccent),
                  hintText: 'http://pametno-vozilo.local:1607',
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cyanAccent, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Preset URL chips
              Wrap(
                spacing: 8,
                children: [
                  _buildPresetChip(RobotConstants.defaultHost, 'Default mDNS'),
                  _buildPresetChip('http://localhost:1607', 'Localhost'),
                  _buildPresetChip('http://192.168.1.105:1607', 'Direct IP'),
                ],
              ),

              const SizedBox(height: 20),

              // OCR AutoPilot Test Trigger (Interactive Testing)
              const Text(
                'OCR / AUTOPILOT TEST INJECTOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildOcrTestChip('FORWARD', 'forward'),
                  _buildOcrTestChip('LEFT', 'left'),
                  _buildOcrTestChip('RIGHT', 'right'),
                  _buildOcrTestChip('BACK', 'back'),
                  _buildOcrTestChip('ROTATE', 'rotate'),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSaveHost(_hostController.text);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'APPLY SETTINGS',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String url, String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.surfaceBorderSubtle),
      onPressed: () {
        _hostController.text = url;
      },
    );
  }

  Widget _buildOcrTestChip(String label, String keyword) {
    return ActionChip(
      avatar: const Icon(Icons.send_rounded, size: 12, color: AppColors.cyanAccent),
      label: Text('Inject "$label"'),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.cyanAccent),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.surfaceBorder),
      onPressed: () {
        widget.onInjectOcrText(keyword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simulated OCR text injected: "$keyword"'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
