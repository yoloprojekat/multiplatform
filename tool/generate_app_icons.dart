import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() async {
  const masterPath =
      r'C:\Users\danil\.gemini\antigravity-ide\brain\08a25525-446c-4dae-8329-c5204ab7378b\smart_vehicle_app_icon_1790139644339.jpg';

  final masterFile = File(masterPath);
  if (!masterFile.existsSync()) {
    stderr.writeln('Master icon file not found at: $masterPath');
    exit(1);
  }

  final masterBytes = masterFile.readAsBytesSync();
  final masterImg = img.decodeImage(masterBytes);
  if (masterImg == null) {
    stderr.writeln('Failed to decode master image');
    exit(1);
  }


  // Save source in assets/icons
  final assetsDir = Directory('assets/icons');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync(recursive: true);
  }
  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(masterImg));

  // Helper to write resized PNG
  void writePng(String outPath, int size) {
    final resized = img.copyResize(
      masterImg,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );
    final file = File(outPath);
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    file.writeAsBytesSync(img.encodePng(resized));
  }

  // 1. Android Mipmap Icons
  final androidSizes = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };
  for (final entry in androidSizes.entries) {
    writePng(entry.key, entry.value);
  }

  // 2. iOS AppIcon.appiconset
  const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final iosSizes = {
    '$iosDir/Icon-App-20x20@1x.png': 20,
    '$iosDir/Icon-App-20x20@2x.png': 40,
    '$iosDir/Icon-App-20x20@3x.png': 60,
    '$iosDir/Icon-App-29x29@1x.png': 29,
    '$iosDir/Icon-App-29x29@2x.png': 58,
    '$iosDir/Icon-App-29x29@3x.png': 87,
    '$iosDir/Icon-App-40x40@1x.png': 40,
    '$iosDir/Icon-App-40x40@2x.png': 80,
    '$iosDir/Icon-App-40x40@3x.png': 120,
    '$iosDir/Icon-App-60x60@2x.png': 120,
    '$iosDir/Icon-App-60x60@3x.png': 180,
    '$iosDir/Icon-App-76x76@1x.png': 76,
    '$iosDir/Icon-App-76x76@2x.png': 152,
    '$iosDir/Icon-App-83.5x83.5@2x.png': 167,
    '$iosDir/Icon-App-1024x1024@1x.png': 1024,
  };
  for (final entry in iosSizes.entries) {
    writePng(entry.key, entry.value);
  }

  // 3. macOS AppIcon.appiconset
  const macDir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';
  final macSizes = {
    '$macDir/app_icon_16.png': 16,
    '$macDir/app_icon_32.png': 32,
    '$macDir/app_icon_64.png': 64,
    '$macDir/app_icon_128.png': 128,
    '$macDir/app_icon_256.png': 256,
    '$macDir/app_icon_512.png': 512,
    '$macDir/app_icon_1024.png': 1024,
  };
  for (final entry in macSizes.entries) {
    writePng(entry.key, entry.value);
  }

  // 4. Web icons
  final webSizes = {
    'web/favicon.png': 32,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
  };
  for (final entry in webSizes.entries) {
    writePng(entry.key, entry.value);
  }

  // 5. Windows app_icon.ico
  final icoSizes = [16, 32, 48, 64, 128, 256];
  final icoBytes = _createIcoFile(masterImg, icoSizes);
  final icoFile = File('windows/runner/resources/app_icon.ico');
  icoFile.writeAsBytesSync(icoBytes);

}

Uint8List _createIcoFile(img.Image masterImg, List<int> sizes) {
  final pngList = <Uint8List>[];
  for (final size in sizes) {
    final resized = img.copyResize(
      masterImg,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );
    pngList.add(Uint8List.fromList(img.encodePng(resized)));
  }

  final headerLength = 6;
  final dirEntryLength = 16;
  final totalDirLength = headerLength + (dirEntryLength * sizes.length);

  int currentOffset = totalDirLength;
  final builder = BytesBuilder();

  // ICO Header: 0x0000 (reserved), 0x0001 (type icon), count (2 bytes)
  builder.add([0, 0, 1, 0, sizes.length & 0xFF, (sizes.length >> 8) & 0xFF]);

  // Directory entries
  for (int i = 0; i < sizes.length; i++) {
    final size = sizes[i];
    final png = pngList[i];
    final widthByte = size >= 256 ? 0 : size;
    final heightByte = size >= 256 ? 0 : size;

    builder.add([
      widthByte,
      heightByte,
      0, // Color palette count (0 = no palette)
      0, // Reserved
      1, 0, // Color planes
      32, 0, // Bits per pixel (32-bit RGBA)
      png.length & 0xFF,
      (png.length >> 8) & 0xFF,
      (png.length >> 16) & 0xFF,
      (png.length >> 24) & 0xFF,
      currentOffset & 0xFF,
      (currentOffset >> 8) & 0xFF,
      (currentOffset >> 16) & 0xFF,
      (currentOffset >> 24) & 0xFF,
    ]);

    currentOffset += png.length;
  }

  // PNG data chunks
  for (final png in pngList) {
    builder.add(png);
  }

  return builder.toBytes();
}
