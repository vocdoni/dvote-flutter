import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

Future<Uint8List> httpGetWithTimeout(String url, {int timeout = 15}) {
  if (!(url is String)) return Future.error(Exception("Invalid URL"));

  Completer<Uint8List> completer = Completer<Uint8List>();

  // Request
  http.get(url).then((response) {
    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300) throw Exception();

    if (!completer.isCompleted) completer.complete(response.bodyBytes);
  }).catchError((err) {
    if (!completer.isCompleted) completer.completeError(err);
  });

  // Fail after timeout
  Timer(Duration(seconds: timeout ?? 15), () {
    if (!completer.isCompleted) completer.completeError(Exception("Time out"));
  });

  return completer.future;
}

Future<String> httpGetStringWithTimeout(String url, {int timeout = 15}) {
  if (!(url is String)) return Future.error(Exception("Invalid URL"));

  Completer<String> completer = Completer<String>();

  // Request
  http.get(url).then((response) {
    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300) throw Exception();

    if (!completer.isCompleted) completer.complete(response.body);
  }).catchError((err) {
    if (!completer.isCompleted) completer.completeError(err);
  });

  // Fail after timeout
  Timer(Duration(seconds: timeout ?? 15), () {
    if (!completer.isCompleted) completer.completeError(Exception("Time out"));
  });

  return completer.future;
}
