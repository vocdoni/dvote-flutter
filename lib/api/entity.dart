import "dart:async";
import 'dart:developer';
import 'dart:typed_data';
import 'package:dvote/blockchain/ens.dart';
import 'package:dvote/net/gateway-pool.dart';
import 'package:dvote/net/gateway-web3.dart';
import 'package:dvote/wrappers/content-uri.dart';
import 'package:convert/convert.dart';
import 'package:dvote/util/parsers.dart';
import 'package:dvote/wrappers/entities.dart';

import '../models/build/dart/metadata/entity.pb.dart';
import './file.dart';

/// Fetches the content URI for a given entity's metadata from the blockchain.
Future<ContentURI> fetchEntityContentUri(
    EntityReference entityRef, GatewayPool gw) async {
  List<dynamic> result;
  final hexEntityId = hex.decode(entityRef.entityId.replaceFirst("0x", ""));
  try {
    final params = [
      ensHashAddress(Uint8List.fromList(hexEntityId)),
      TextRecordKeys.JSON_METADATA_CONTENT_URI
    ];
    result = await gw.callMethod("text", params, ContractEnum.EntityResolver);
    if (result == null || result.length == 0 || result.first == null)
      throw Exception("The metadata of the entity can't be found");
    else if (result[0] is! String || result[0].length == 0)
      throw Exception("The response from the blockchain is invalid");
  } catch (err) {
    log("${err.toString()}");
    throw err;
  }

  // Fetch the JSON from the network
  return ContentURI(result[0]);
}

/// Fetches a given entity's metadata using [ipfsUri] if provided.
Future<EntityMetadata> fetchEntity(EntityReference entityRef, GatewayPool gw,
    {ContentURI ipfsUri}) async {
  String meta;
  List<dynamic> result;

  if (entityRef is! EntityReference || gw is! GatewayPool) {
    throw Exception("Invalid parameters");
  }

  // If no ContentUri is supplied, determine the latest content uri
  if (ipfsUri == null) {
    // Fetch the Content URI from the blockchain
    final hexEntityId = hex.decode(entityRef.entityId.replaceFirst("0x", ""));
    try {
      final params = [
        ensHashAddress(Uint8List.fromList(hexEntityId)),
        TextRecordKeys.JSON_METADATA_CONTENT_URI
      ];
      result = await gw.callMethod("text", params, ContractEnum.EntityResolver);
      if (result == null || result.length == 0 || result.first == null)
        throw Exception("The metadata of the entity can't be found");
      else if (result[0] is! String || result[0].length == 0)
        throw Exception("The response from the blockchain is invalid");
    } catch (err) {
      log("${err.toString()}");
      throw err;
    }

    // Fetch the JSON from the network
    ipfsUri = ContentURI(result[0]);
  }
  try {
    meta = await fetchFileString(ipfsUri, gw);
  } catch (err) {
    throw Exception("Could not fetch the entity metadata: $err");
  }

  try {
    final res = parseEntityMetadata(meta);
    return res;
  } catch (err) {
    throw Exception("The JSON metadata is not valid");
  }
}
