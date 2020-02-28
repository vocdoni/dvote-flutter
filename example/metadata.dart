import 'package:dvote/dvote.dart';
import './constants.dart';
import 'dart:convert';

Future<void> metadata() async {
  EntityReference entity = EntityReference();
  entity.entityId = ENTITY_ID;
  entity.entryPoints.addAll(["https://rpc.slock.it/goerli"]);

  try {
    final gwInfo = await getRandomDefaultGatewayDetails(NETWORK_ID);
    final dvoteGw = DVoteGateway(gwInfo.dvote, publicKey: gwInfo.publicKey);
    final web3Gw = Web3Gateway(gwInfo.web3);

    final entityMeta = await fetchEntity(entity, dvoteGw, web3Gw);

    final String pid = entityMeta.votingProcesses?.active?.first;
    if (pid is String) {
      final processMeta = await getProcessMetadata(pid, dvoteGw, web3Gw);
      print(jsonEncode(processMeta));
    }
  } catch (err) {
    print(err);
  }
}
