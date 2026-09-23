import 'package:http/http.dart' as http;
import 'http_client_factory_stub.dart'
    if (dart.library.js_interop) 'http_client_factory_web.dart'
    if (dart.library.io) 'http_client_factory_io.dart';

/// Creates an HTTP client configured with platform-level socket connection timeouts
/// (e.g. 2.5s) to prevent hanging for 60 seconds on unresolved or unreachable LAN hosts.
http.Client createHttpClient({
  Duration timeout = const Duration(milliseconds: 2500),
}) {
  return createPlatformHttpClient(timeout: timeout);
}
