import 'dart:typed_data';

/// Utility class to parse continuous MJPEG HTTP streams into discrete JPEG frames.
class MjpegDecoder {
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  static const int maxBufferSize = 5 * 1024 * 1024; // 5 MB safety limit

  /// Processes an incoming raw byte chunk from the stream.
  /// Returns a list of complete JPEG byte arrays found in the accumulated buffer.
  List<Uint8List> processChunk(Uint8List chunk) {
    _buffer.add(chunk);
    final accumulated = _buffer.toBytes();
    final frames = <Uint8List>[];

    int searchOffset = 0;
    while (true) {
      final startIndex = _findJpegStart(accumulated, searchOffset);
      if (startIndex == -1) {
        break;
      }

      final endIndex = _findJpegEnd(accumulated, startIndex);
      if (endIndex == -1) {
        break;
      }

      // JPEG frame includes the 2-byte EOI marker: endIndex + 2
      final frameLength = (endIndex + 2) - startIndex;
      final frameBytes = Uint8List.sublistView(accumulated, startIndex, startIndex + frameLength);
      frames.add(Uint8List.fromList(frameBytes));

      searchOffset = endIndex + 2;
    }

    _buffer.clear();
    if (searchOffset > 0 && searchOffset < accumulated.length) {
      // Keep unparsed trailing bytes
      _buffer.add(Uint8List.sublistView(accumulated, searchOffset));
    } else if (searchOffset == 0 && accumulated.length > maxBufferSize) {
      // Emergency reset if no valid frame boundaries found and buffer grew too large
      _buffer.clear();
    }

    return frames;
  }

  void reset() {
    _buffer.clear();
  }

  static int _findJpegStart(Uint8List data, int startFrom) {
    final limit = data.length - 1;
    for (int i = startFrom; i < limit; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD8) {
        return i;
      }
    }
    return -1;
  }

  static int _findJpegEnd(Uint8List data, int startIndex) {
    final limit = data.length - 1;
    for (int i = startIndex; i < limit; i++) {
      if (data[i] == 0xFF && data[i + 1] == 0xD9) {
        return i;
      }
    }
    return -1;
  }
}
