/// Hash the given hex payload and return a base64 string
Future<String> poseidonHash(String hexPayload) async {
  if (!(hexPayload is String) || hexPayload.length == 0)
    throw Exception("The payload is empty");

  // TODO: UNAVAILABLE ON NATIVE DART
  throw Exception("UNIMPLEMENTED");
}
