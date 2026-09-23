// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final port = 8085;
  final webDir = Directory('build/web');
  if (!webDir.existsSync()) {
    print('build/web directory does not exist!');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Serving build/web on http://localhost:$port');

  await for (final request in server) {
    var path = request.uri.path;
    if (path == '/' || path.isEmpty) {
      path = '/index.html';
    }

    final file = File('${webDir.path}$path');
    if (await file.exists()) {
      final ext = path.split('.').last.toLowerCase();
      String contentType = 'application/octet-stream';
      if (ext == 'html') contentType = 'text/html';
      if (ext == 'js') contentType = 'application/javascript';
      if (ext == 'css') contentType = 'text/css';
      if (ext == 'json') contentType = 'application/json';
      if (ext == 'png') contentType = 'image/png';
      if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';
      if (ext == 'gif') contentType = 'image/gif';
      if (ext == 'wasm') contentType = 'application/wasm';
      if (ext == 'otf' || ext == 'ttf') contentType = 'font/otf';

      request.response.headers.set('Content-Type', contentType);
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      await file.openRead().pipe(request.response);
    } else {
      final indexHtml = File('${webDir.path}/index.html');
      request.response.headers.set('Content-Type', 'text/html');
      await indexHtml.openRead().pipe(request.response);
    }
  }
}
