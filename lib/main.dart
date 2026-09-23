import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/robot_controller.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/cockpit_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation & status bar colors for dark cockpit styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090C12),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const YoloVoziloApp());
}

class YoloVoziloApp extends StatefulWidget {
  const YoloVoziloApp({super.key});

  @override
  State<YoloVoziloApp> createState() => _YoloVoziloAppState();
}

class _YoloVoziloAppState extends State<YoloVoziloApp> {
  late final RobotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RobotController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLO VOZILO Cockpit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: CockpitScreen(controller: _controller),
    );
  }
}
