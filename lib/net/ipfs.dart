import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dvote/net/http.dart';

const IPFS_GATEWAY_LIST_URI =
    "https://ipfs.github.io/public-gateway-checker/gateways.json";

/// Launches 3 concurrent requests to well-known IPFS gateways and returns
/// the valid response of the first of them to reply.
/// Produces a time out after 20 seconds
Future<Uint8List> fetchIpfsHash(String hash) {
  return _getRandomIpfsURLs().then((gwList) {
    return Future.any(gwList
        .map((gwUrl) => httpGetWithTimeout(
            gwUrl.replaceFirst(RegExp(":hash"), hash),
            timeout: 15))
        .cast<Future<Uint8List>>()
        .toList());
  });
}

Future<List<String>> _getRandomIpfsURLs() {
  return httpGetStringWithTimeout(IPFS_GATEWAY_LIST_URI, timeout: 8)
      .then((gwResponse) {
    final list = jsonDecode(gwResponse);
    if (list is List) {
      return _shuffledList(list.whereType<String>().toList()).sublist(0, 2);
    } else
      throw Exception("Invalid gateway list response");
  });
}

List<String> _shuffledList(List<String> items) {
  var random = Random.secure();

  items.sort((_, __) => random.nextBool() ? 1 : -1);
  return items.whereType<String>().cast<String>().toList();
}
