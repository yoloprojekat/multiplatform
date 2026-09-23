import 'dart:typed_data';

abstract class FileSaverPlatform {
  Future<String?> saveFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  });
}
