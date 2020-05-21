import "dart:async";
import 'dart:typed_data';
import 'package:dvote/net/gateway.dart';
import 'package:dvote/util/dev.dart';
import 'package:dvote/wrappers/content-uri.dart';
import 'package:convert/convert.dart';
import 'package:dvote/util/parsers.dart';

import '../blockchain/index.dart';
import '../models/dart/entity.pb.dart';
import './file.dart';

/// ENS keys used to store the Text Records on the Smart Contract
const Map<String, String> TEXT_RECORD_KEYS = {
  "JSON_METADATA_CONTENT_URI": "vnd.vocdoni.meta",
  "VOCDONI_BOOT_NODES": "vnd.vocdoni.boot-nodes",
  "VOCDONI_GATEWAY_HEARTBEAT": "vnd.vocdoni.gateway-heartbeat"
};

Future<EntityMetadata> fetchEntity(
    EntityReference entityRef, DVoteGateway dvoteGw, Web3Gateway web3Gw) async {
  String meta;
  List<dynamic> result;

  if (!(entityRef is EntityReference) ||
      !(dvoteGw is DVoteGateway) ||
      !(web3Gw is Web3Gateway)) {
    throw Exception("Invalid parameters");
  }

  // Fetch the Content URI from the blockchain
  final hexEntityId = hex.decode(entityRef.entityId.substring(2));
  try {
    result = await callEntityResolverMethod(web3Gw.rpcUri, "text", [
      Uint8List.fromList(hexEntityId),
      TEXT_RECORD_KEYS["JSON_METADATA_CONTENT_URI"]
    ]);
    if (result == null || result.length == 0 || result.first == null)
      throw Exception("The metadata of the entity can't be found");
    else if (!(result[0] is String) || result[0].length == 0)
      throw Exception("The response from the blockchain is invalid");
  } catch (err) {
    devPrint(err);
    throw err;
  }

  // Fetch the JSON from the network
  final contentUri = ContentURI(result[0]);
  try {
    meta = await fetchFileString(contentUri, dvoteGw);
  } catch (err) {
    throw Exception("Could not fetch the entity metadata");
  }

  try {
    final res = parseEntityMetadata(meta);
    return res;
  } catch (err) {
    throw Exception("The JSON metadata is not valid");
  }
}
