import 'dart:math';

import 'package:dvote/net/gateway-web3.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:dvote/wrappers/entities.dart';

import "../constants.dart";
import 'package:http/http.dart' as http;

import '../models/dart/gateway.pb.dart';
import '../util/parsers.dart';
import 'package:dvote/util/dev.dart';
// import 'package:flutter/foundation.dart'; // for kReleaseMode

var random = Random.secure();

/// Retrieve the Content URI of the boot nodes Content URI provided by Vocdoni.
/// `networkId` should be among "mainnet", "goerli" or "xdai"
Future<String> resolveWellKnownBootnodeUri(String networkId) async {
  List<String> providerUris;
  String entityId;

  switch (networkId) {
    case "mainnet":
      providerUris = ["https://api.etherscan.io", "https://cloudflare-eth.com"];
      entityId = VOCDONI_MAINNET_ENTITY_ID;
      break;
    case "goerli":
      providerUris = ["https://rpc.slock.it/goerli"];
      entityId = VOCDONI_GOERLI_ENTITY_ID;
      break;
    case "xdai":
      providerUris = ["https://dai.poa.network"];
      entityId = VOCDONI_XDAI_ENTITY_ID;
      break;
    default:
      throw Exception("Invalid Network ID");
  }
  providerUris.shuffle(random);

  final hexEntityId = hex.decode(entityId.substring(2));

  for (var uri in providerUris) {
    try {
      final gw = Web3Gateway(uri);
      var result = await gw.callMethod(
          "text",
          [Uint8List.fromList(hexEntityId), TextRecordKeys.VOCDONI_BOOT_NODES],
          ContractEnum.EntityResolver);
      if (result is List && result[0] is String) return result[0];
    } catch (err) {
      continue;
    }
  }

  throw Exception("Could not determine the boot node URI for " + networkId);
}

/// Retrieve a set of gateways parsed from the given link
/// The link contents must conform to the schema defined on
/// https://vocdoni.io/docs/#/architecture/components/bootnode
Future<BootNodeGateways> fetchBootnodeInfo(String bootnodeUri) async {
  try {
    var response = await http.get(bootnodeUri);
    if (response is! http.Response ||
        response.statusCode < 200 ||
        response.statusCode >= 300)
      throw Exception("The gateway information could not be fetched");

    return parseBootnodeInfo(response.body);
  } catch (err) {
    devPrint(err);
    throw err;
  }
}
