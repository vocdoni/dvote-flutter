import 'package:dvote_native/dvote_native.dart' as dvoteNative;

/// Hash the given hex payload and return a base64 string
Future<String> poseidonHash(String hexPayload) async {
  if (!(hexPayload is String) || hexPayload.length == 0)
    throw Exception("The payload is empty");

  // TODO: IMPLEMENT IN NATIVE DART
  return dvoteNative.poseidonHash(hexPayload);
}
