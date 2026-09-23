import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/robot_command.dart';
import 'mjpeg_stream_service.dart';

class MockRobotService {
  Timer? _streamTimer;
  bool _isVisionOn = false;
  bool _isFollowOn = false;
  RobotCommand _lastCommand = RobotCommand.stop;
  int _frameIndex = 0;

  bool get isStreaming => _streamTimer != null;

  void startMockStream({
    required OnFrameCallback onFrame,
    required OnStreamConnectedCallback onConnected,
  }) {
    stopMockStream();
    onConnected();

    _streamTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      _frameIndex++;
      final frameBytes = _generateMockFrame(_frameIndex);
      onFrame(frameBytes, 30.0);
    });
  }

  void stopMockStream() {
    _streamTimer?.cancel();
    _streamTimer = null;
  }

  void updateCommand(RobotCommand cmd) {
    _lastCommand = cmd;
  }

  void setVision(bool enable) {
    _isVisionOn = enable;
    if (!enable) _isFollowOn = false;
  }

  void setFollow(bool enable) {
    _isFollowOn = enable;
  }

  Uint8List _generateMockFrame(int step) {
    const width = 480;
    const height = 270;
    final image = img.Image(width: width, height: height);

    // Background gradient (cockpit HUD simulation)
    for (int y = 0; y < height; y++) {
      final intensity = (15 + (y * 25 / height)).toInt();
      final color = img.ColorRgb8(
        intensity ~/ 2,
        intensity,
        (intensity * 1.4).toInt().clamp(0, 255),
      );
      for (int x = 0; x < width; x++) {
        image.setPixel(x, y, color);
      }
    }

    // Draw horizontal grid line
    const horizonY = height ~/ 2;
    img.drawLine(
      image,
      x1: 40,
      y1: horizonY,
      x2: width - 40,
      y2: horizonY,
      color: img.ColorRgb8(0, 150, 200),
    );

    // Draw simulated motion horizon bars
    final offset = (step * 3) % 40;
    for (int y = horizonY + offset; y < height; y += 35) {
      img.drawLine(
        image,
        x1: width ~/ 2 - (y - horizonY) * 2,
        y1: y,
        x2: width ~/ 2 + (y - horizonY) * 2,
        y2: y,
        color: img.ColorRgb8(0, 90, 130),
      );
    }

    // Draw crosshair in center
    const cx = width ~/ 2;
    const cy = height ~/ 2;
    img.drawCircle(
      image,
      x: cx,
      y: cy,
      radius: 24,
      color: img.ColorRgb8(0, 229, 255),
    );
    img.drawLine(
      image,
      x1: cx - 35,
      y1: cy,
      x2: cx - 12,
      y2: cy,
      color: img.ColorRgb8(0, 229, 255),
    );
    img.drawLine(
      image,
      x1: cx + 12,
      y1: cy,
      x2: cx + 35,
      y2: cy,
      color: img.ColorRgb8(0, 229, 255),
    );
    img.drawLine(
      image,
      x1: cx,
      y1: cy - 35,
      x2: cx,
      y2: cy - 12,
      color: img.ColorRgb8(0, 229, 255),
    );
    img.drawLine(
      image,
      x1: cx,
      y1: cy + 12,
      x2: cx,
      y2: cy + 35,
      color: img.ColorRgb8(0, 229, 255),
    );

    // Simulated Vision Bounding Box if AI detection is ON
    if (_isVisionOn) {
      final boxX = cx - 50 + ((sin(step * 0.1) * 30).toInt());
      const boxY = cy - 40;
      const boxW = 80;
      const boxH = 90;

      // Draw bounding box
      img.drawRect(
        image,
        x1: boxX,
        y1: boxY,
        x2: boxX + boxW,
        y2: boxY + boxH,
        color: img.ColorRgb8(0, 230, 118),
      );

      // Label background
      img.fillRect(
        image,
        x1: boxX,
        y1: boxY - 14,
        x2: boxX + 75,
        y2: boxY,
        color: img.ColorRgb8(0, 230, 118),
      );

      img.drawString(
        image,
        _isFollowOn ? 'TARGET: LOCK' : 'PERSON 94%',
        font: img.arial14,
        x: boxX + 2,
        y: boxY - 13,
        color: img.ColorRgb8(0, 0, 0),
      );
    }

    // Telemetry text
    img.drawString(
      image,
      'SIMULATOR FEED • CMD: ${_lastCommand.label}',
      font: img.arial14,
      x: 10,
      y: 10,
      color: img.ColorRgb8(0, 229, 255),
    );

    return Uint8List.fromList(img.encodeJpg(image, quality: 75));
  }
}
