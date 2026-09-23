import 'dart:typed_data';
import 'file_saver_platform.dart';

class FileSaverStub implements FileSaverPlatform {
  @override
  Future<String?> saveFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    return null;
  }
}

FileSaverPlatform getFileSaver() => FileSaverStub();
