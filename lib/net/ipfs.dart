import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import "../util/timeout.dart";

const IPFS_GATEWAY_LIST_URI =
    "https://ipfs.github.io/public-gateway-checker/gateways.json";

/// Launches concurrent requests to well-known IPFS gateways and returns
/// the valid response of the first of them to reply.
/// Produces a time out after 15 seconds
Future<Uint8List> fetchIpfsHash(String hash) {
  return _getRandomIpfsURLs(3).then((gwList) {
    return Future.any(gwList
            .map((gwUrl) {
              final uri = gwUrl.replaceFirst(RegExp(":hash"), hash);
              return http.get(uri).withTimeout(Duration(seconds: 8));
            })
            .cast<Future<Uint8List>>()
            .toList())
        .withTimeout(Duration(seconds: 15));
  });
}

Future<List<String>> _getRandomIpfsURLs(int count) {
  return http
      .get(IPFS_GATEWAY_LIST_URI)
      .withTimeout(Duration(seconds: 8))
      .then((gwResponse) {
    final list = jsonDecode(gwResponse.body);
    if (list is! List) throw Exception("Invalid gateway list response");

    final endpoints = (list as List<String>).whereType<String>().toList();
    endpoints.shuffle(Random.secure());
    return endpoints.sublist(0, count - 1);
  });
}
