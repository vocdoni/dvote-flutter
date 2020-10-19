import 'dart:async';

extension WithTimeout<T> on Future<T> {
  Future<T> withTimeout([Duration timeout = const Duration(seconds: 7)]) {
    final completer = Completer<T>();

    // Fail after timeout
    final timer = Timer(timeout, () {
      if (completer.isCompleted) return; // skip

      completer.completeError(TimeoutException("Time out"));
    });

    // Request
    this.then((result) {
      if (completer.isCompleted) return; // skip

      completer.complete(result);
      timer.cancel();
    }).catchError((err) {
      if (completer.isCompleted) return; // skip

      completer.completeError(err);
      timer.cancel();
    });

    return completer.future;
  }
}
