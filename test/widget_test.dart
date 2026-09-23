import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiplatform/controllers/robot_controller.dart';
import 'package:multiplatform/core/utils/mjpeg_decoder.dart';
import 'package:multiplatform/data/models/robot_command.dart';
import 'package:multiplatform/ui/screens/cockpit_screen.dart';

void main() {
  group('RobotCommand Tests', () {
    test('Correct command codes mapped', () {
      expect(RobotCommand.forward.code, 'napred');
      expect(RobotCommand.backward.code, 'nazad');
      expect(RobotCommand.left.code, 'levo');
      expect(RobotCommand.right.code, 'desno');
      expect(RobotCommand.rotateLeft.code, 'rot_levo');
      expect(RobotCommand.rotateRight.code, 'rot_desno');
      expect(RobotCommand.stop.code, 'stop');
    });

    test('RobotCommand.fromCode returns correct enum', () {
      expect(RobotCommand.fromCode('napred'), RobotCommand.forward);
      expect(RobotCommand.fromCode('invalid'), RobotCommand.stop);
    });
  });

  group('MjpegDecoder Tests', () {
    test('Parses full JPEG frame', () {
      final decoder = MjpegDecoder();
      // Synthetic JPEG with SOI (0xFF, 0xD8) and EOI (0xFF, 0xD9)
      final dummyJpeg = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0x01, 0x02, 0x03, 0x04,
        0xFF, 0xD9, // EOI
      ]);

      final frames = decoder.processChunk(dummyJpeg);
      expect(frames.length, 1);
      expect(frames.first.length, dummyJpeg.length);
      expect(frames.first[0], 0xFF);
      expect(frames.first[1], 0xD8);
      expect(frames.first.last, 0xD9);
    });
  });

  group('Cockpit UI Smoke Tests', () {
    testWidgets('App renders Cockpit UI correctly', (WidgetTester tester) async {
      // Set test viewport size
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = RobotController();
      controller.setSimulatorMode(true);

      await tester.pumpWidget(
        MaterialApp(
          home: CockpitScreen(controller: controller),
        ),
      );
      await tester.pump();

      // Verify Title & Status
      expect(find.text('YOLO VOZILO'), findsOneWidget);
      expect(find.text('STREAM STANDBY'), findsOneWidget);

      // Verify Feature Action Buttons
      expect(find.text('VISION OFF'), findsOneWidget);
      expect(find.text('RECORD'), findsOneWidget);

      // Verify D-Pad is default
      expect(find.text('COMPACT D-PAD'), findsOneWidget);
      expect(find.text('▲'), findsOneWidget);
      expect(find.text('▼'), findsOneWidget);
      expect(find.text('◀'), findsOneWidget);
      expect(find.text('▶'), findsOneWidget);

      // Toggle to Joystick
      final joystickSwitch = find.byType(Switch).first;
      await tester.tap(joystickSwitch);
      await tester.pump();

      expect(find.text('VIRTUAL JOYSTICK'), findsOneWidget);

      controller.dispose();
    });
  });
}
