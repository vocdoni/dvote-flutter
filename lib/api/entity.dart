import "dart:async";
import 'dart:developer';
import 'dart:typed_data';
import 'package:dvote/blockchain/ens.dart';
import 'package:dvote/net/gateway-pool.dart';
import 'package:dvote/net/gateway-web3.dart';
import 'package:dvote/wrappers/content-uri.dart';
import 'package:convert/convert.dart';
import 'package:dvote/util/parsers.dart';
import 'package:hex/hex.dart';
import 'package:dvote/wrappers/entities.dart';

import '../models/build/dart/metadata/entity.pb.dart';
import './file.dart';

Future<EntityMetadata> fetchEntity(
    EntityReference entityRef, GatewayPool gw) async {
  String meta;
  List<dynamic> result;

  if (entityRef is! EntityReference || gw is! GatewayPool) {
    throw Exception("Invalid parameters");
  }

  // Fetch the Content URI from the blockchain
  final hexEntityId = hex.decode(entityRef.entityId.substring(2));
  print(entityRef.entityId);
  print(HEX.encode(ensHashAddress(Uint8List.fromList(hexEntityId))));
  try {
    final params = [
      ensHashAddress(Uint8List.fromList(hexEntityId)),
      TextRecordKeys.JSON_METADATA_CONTENT_URI
    ];
    print(params);
    result = await gw.callMethod("text", params, ContractEnum.EntityResolver);
    print(result);
    if (result == null || result.length == 0 || result.first == null)
      throw Exception("The metadata of the entity can't be found");
    else if (result[0] is! String || result[0].length == 0)
      throw Exception("The response from the blockchain is invalid");
  } catch (err, s) {
    log("${err.toString()}, $s");
    throw err;
  }

  // Fetch the JSON from the network
  final contentUri = ContentURI(result[0]);
  try {
    meta = await fetchFileString(contentUri, gw);
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
