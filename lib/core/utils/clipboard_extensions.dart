import 'dart:async';
import 'dart:typed_data';
import 'package:super_clipboard/super_clipboard.dart';

extension DataReaderFuture on DataReader {
  /// Reads a value of type [T] from the reader.
  Future<T?> readValue<T extends Object>(ValueFormat<T> format) {
    final completer = Completer<T?>();
    getValue(
      format,
      (value) => completer.complete(value),
      onError: (error) => completer.complete(null),
    );
    return completer.future;
  }

  /// Reads a file from the reader and returns its contents as [Uint8List].
  Future<Uint8List?> readFileValue(FileFormat format) {
    final completer = Completer<Uint8List?>();
    getFile(format, (file) async {
      try {
        final bytes = await file.readAll();
        completer.complete(bytes);
      } catch (e) {
        completer.complete(null);
      }
    }, onError: (error) => completer.complete(null));
    return completer.future;
  }
}
