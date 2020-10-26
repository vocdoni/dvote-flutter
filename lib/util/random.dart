import 'dart:math';
import 'dart:convert';

final _random = Random.secure();

/// Returns a base64 representation of a random buffer of the given size
String makeRandomId([int byteCount = 16]) {
  final values = List<int>.generate(byteCount, (i) => _random.nextInt(256));
  return base64.encode(values);
}

/// Returns a random hexadecimal string of the given length
String makeRandomNonce(int length) {
  final digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f'
  ];
  var result = "";
  for (var i = 0; i < length; i++) {
    result = result + digits[_random.nextInt(digits.length)];
  }
  return result;
}
