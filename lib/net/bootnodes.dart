import 'dart:convert';
import 'dart:math';

import 'package:dvote/util/dev.dart';
import 'package:dvote/wrappers/content-uri.dart';
import 'package:dvote/blockchain/index.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:dvote/wrappers/entities.dart';

import "../constants.dart";
import 'package:http/http.dart' as http;

import '../models/dart/gateway.pb.dart';
import '../util/parsers.dart';
// import 'package:flutter/foundation.dart'; // for kReleaseMode

var random = Random.secure();

/// Retrieve the Content URI of the boot nodes Content URI provided by Vocdoni.
/// `networkId` should be either "mainnet" or "goerli"
Future<ContentURI> getDefaultBootnodeContentUri(String networkId) async {
  List<String> providerUris;

  switch (networkId) {
    case "mainnet":
      providerUris = ["https://api.etherscan.io", "https://cloudflare-eth.com"];
      break;
    case "goerli":
      providerUris = [
        "https://rpc.slock.it/goerli",
        "https://rpc.goerli.mudit.blog",
        "https://goerli.prylabs.net",
        // "http://goerli.blockscout.com",
      ];
      break;
    case "xdai":
      providerUris = ["https://dai.poa.network"];
      break;
    default:
      throw Exception("Invalid Network ID");
  }
  providerUris.shuffle(Random.secure());

  String entityId;
  switch (networkId) {
    case "mainnet":
      entityId = VOCDONI_MAINNET_ENTITY_ID;
      break;
    case "goerli":
      entityId = VOCDONI_GOERLI_ENTITY_ID;
      break;
    case "xdai":
      entityId = VOCDONI_XDAI_ENTITY_ID;
      break;
    default:
      throw Exception("Invalid network ID");
  }

  final hexEntityId = hex.decode(entityId.substring(2));

  for (var uri in providerUris) {
    try {
      var result = await callEntityResolverMethod(uri, "text", [
        Uint8List.fromList(hexEntityId),
        TextRecordKeys.VOCDONI_BOOT_NODES
      ]);
      if (result is List && result[0] is String) return ContentURI(result[0]);
    } catch (err) {
      continue;
    }
  }

  throw Exception("The boot nodes Content URI is not defined on " + networkId);
}

/// Fetch the blockchain to retrieve the default gateways provided by Vocdoni
Future<BootNodeGateways> getDefaultGatewaysDetails(String networkId) {
  return getDefaultBootnodeContentUri(networkId)
      .then((uri) => getGatewaysDetailsFromBootNode(uri.toString()));
}

/// Retrieve a set of gateways parsed from the given link
/// The link contents must conform to the schema defined on
/// https://vocdoni.io/docs/#/architecture/components/bootnode
Future<BootNodeGateways> getGatewaysDetailsFromBootNode(
    String bootnodesUri) async {
  try {
    var response = await http.get(bootnodesUri.toString());
    if (response == null ||
        response.statusCode < 200 ||
        response.statusCode >= 300)
      throw Exception("The gateway information could not be fetched");

    String strJson = utf8.decode(response.bodyBytes);
    return parseBootnodeGateways(strJson);
  } catch (err) {
    devPrint(err);
    throw err;
  }
}

/// Retrieve the parameters of a randomly chosen DVote and Web3 gateway
Future<GatewayInfo> getRandomDefaultGatewayDetails(String networkId) {
  return getDefaultBootnodeContentUri(networkId)
      .then((uri) => getRandomGatewayDetails(uri.toString(), networkId));
}

Future<GatewayInfo> getRandomGatewayDetails(
    String bootnodesUri, String networkId) async {
  final gws = await getGatewaysDetailsFromBootNode(bootnodesUri);

  BootNodeGateways_NetworkNodes nodes;
  switch (networkId) {
    case "mainnet":
      nodes = gws.homestead;
      break;
    case "goerli":
      nodes = gws.goerli;
      break;
    case "xdai":
      nodes = gws.xdai;
      break;
    default:
      throw Exception("Invalid network ID");
  }
  if (nodes.dvote.length == 0 && nodes.web3.length == 0) return null;

  GatewayInfo result = GatewayInfo();
  if (nodes.dvote.length > 0) {
    final int dvoteIdx = random.nextInt(nodes.dvote.length);
    result.dvote = nodes.dvote[dvoteIdx].uri;
    result.supportedApis.addAll(nodes.dvote[dvoteIdx].apis);
    result.publicKey = nodes.dvote[dvoteIdx].pubKey;
  }
  if (nodes.web3.length > 0) {
    final int web3Idx = random.nextInt(nodes.web3.length);
    result.web3 = nodes.web3[web3Idx].uri;
  }
  return result;
}
