import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'file_saver_platform.dart';

class FileSaverIO implements FileSaverPlatform {
  @override
  Future<String?> saveFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else if (Platform.isIOS || Platform.isMacOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        // Windows / Linux
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (dir == null) return null;
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

FileSaverPlatform getFileSaver() => FileSaverIO();
