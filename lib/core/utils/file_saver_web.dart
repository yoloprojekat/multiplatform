import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'file_saver_platform.dart';

class FileSaverWeb implements FileSaverPlatform {
  @override
  Future<String?> saveFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      final jsArray = [bytes.toJS].toJS;
      final options = web.BlobPropertyBag(type: mimeType);
      final blob = web.Blob(jsArray, options);
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = filename
        ..style.display = 'none';

      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
      return filename;
    } catch (_) {
      return null;
    }
  }
}

FileSaverPlatform getFileSaver() => FileSaverWeb();
