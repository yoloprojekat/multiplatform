import 'dart:typed_data';
import 'file_saver_platform.dart';
import 'file_saver_stub.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

class FileSaver {
  static final FileSaverPlatform _instance = getFileSaver();

  static Future<String?> save({
    required Uint8List bytes,
    required String filename,
    String mimeType = 'application/octet-stream',
  }) {
    return _instance.saveFile(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }
}
