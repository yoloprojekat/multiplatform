import 'package:http/http.dart' as http;

http.Client createPlatformHttpClient({
  Duration timeout = const Duration(milliseconds: 2500),
}) =>
    http.Client();
