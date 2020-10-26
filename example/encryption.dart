import 'dart:developer';
import 'dart:math' as math;
import 'package:dvote/dvote.dart';

final _random = math.Random.secure();
const MESSAGE = "Hello word, I am a message encrypted with Rust";
const PASSPHRASE = "This is a very secure passphrase";

void main() async {
  String encrypted, decrypted;
  DateTime start, mid, end;

  try {
    start = DateTime.now();
    // sync
    encrypted = Symmetric.encryptString(MESSAGE, PASSPHRASE);
    decrypted = Symmetric.decryptString(encrypted, PASSPHRASE);

    mid = DateTime.now();

    // async
    encrypted = await Symmetric.encryptStringAsync(MESSAGE, PASSPHRASE);
    decrypted = await Symmetric.decryptStringAsync(encrypted, PASSPHRASE);

    end = DateTime.now();

    if (!testPriorValues()) {
      log("Values don't match");
    }
    if (!testRandomValues()) {
      log("Values don't match");
    }
  } catch (err) {
    log(err.toString());
  }

  print("Encrypted: $encrypted");
  print("Decrypted: $decrypted");

  print("Duration 1: ${mid.difference(start)}");
  print("Duration 2: ${end.difference(mid)}");
}

bool testPriorValues() {
  // 1
  var encryptedB64 =
      "QCBYWqHesUX8ayKDgN5mDMu2FVyV1o+qgYrOl2ltF6WtUqH/AOql5iBg5/hMyZKUvgoYCIGyKnwhDOSKOm4oljuB0jIfjgGk8LQx1Elo7G5lKyIOWuzuRaJt7p4mMgySFy13gEVtssGm/qjO";
  var passphrase = "Top secret";
  var expectedMessage =
      "Change is a tricky thing, it threatens what we find familiar with...";

  var decryptedMessage = Symmetric.decryptString(encryptedB64, passphrase);
  if (decryptedMessage != expectedMessage) return false;

  // 2
  encryptedB64 =
      "88x7SFd7Y9kffc/AY1rhGLspg5jTuzz8EpDUJxQjMzAc9RgSOalaIhfxGBGwBp4sRbKCepq7TrVlJ43NYKwXpgRAEhHgTdyqHH81ViYj3cMDOH4PnPiIomub6+qg1oyd86qbhNWjEQsE0CnH";
  passphrase = "Top secret";
  expectedMessage =
      "Changes are a hacky thing that threaten what we are familiar with...";

  decryptedMessage = Symmetric.decryptString(encryptedB64, passphrase);
  if (decryptedMessage != expectedMessage) return false;

  // 3
  encryptedB64 =
      "SbhufHJv22HWK9Siy6ZXpRnRqodMTRMSw7zgKJQ0y9oL5nNg3GxpSexa7t3kKX70xbh7cTdnxIcIHfEAdLle7O0hhjyHqLe6X1vcpNemQx1yT9Dom5KJSQ3Iu2NULZHwTImxD7cVw6mjWJW8";
  passphrase = "Ultra top secret";
  expectedMessage =
      "Change is a tricky thing, it threatens what we find familiar with...";
  decryptedMessage = Symmetric.decryptString(encryptedB64, passphrase);
  if (decryptedMessage != expectedMessage) return false;

  // 4
  encryptedB64 =
      "OGiaEN1OpjOywrXCOpyluzRDTsPo8bahvKdJZL7zcXBj6hxxuJ+lJ03jSUkQd7ghQ5gBiNfSq9PETNb/6ZpT++rj1h4ROLU/TCsZWLwquET9FGLKG4GW15X+EYIqKFDLPHiPulE4skKlH/2d";
  passphrase = "Ultra top secret";
  expectedMessage =
      "Changes are a hacky thing that threaten what we are familiar with...";

  decryptedMessage = Symmetric.decryptString(encryptedB64, passphrase);
  if (decryptedMessage != expectedMessage) return false;

  return true;
}

bool testRandomValues() {
  final messages = [
    "Hello there, I am super secret",
    "Super secret",
    "Super super super super secret",
    "The meaning of life is...",
    "The universe is indeed...",
  ];

  String passphrase = "";
  for (int i = 0; i < 16; i++) {
    passphrase += _random.nextInt(16).toRadixString(16);
  }

  for (String msg in messages) {
    final encryptedB64 = Symmetric.encryptString(msg, passphrase);
    var decryptedMessage = Symmetric.decryptString(encryptedB64, passphrase);
    if (decryptedMessage != msg) return false;
  }
  return true;
}
