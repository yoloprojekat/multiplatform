import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createPlatformHttpClient({
  Duration timeout = const Duration(milliseconds: 2500),
  Duration? idleTimeout,
}) {
  final ioClient = HttpClient()
    ..connectionTimeout = timeout
    ..idleTimeout = idleTimeout ?? const Duration(days: 365)
    ..badCertificateCallback = (cert, host, port) => true;
  return IOClient(ioClient);
}
