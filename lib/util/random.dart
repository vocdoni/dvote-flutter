import 'dart:math';
import 'dart:convert';

final _random = Random.secure();

String makeRandomId([int byteCount = 16]) {
  final values = List<int>.generate(byteCount, (i) => _random.nextInt(256));
  return base64.encode(values);
}
