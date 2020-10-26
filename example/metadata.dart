import 'package:dvote/dvote.dart';
import './constants.dart';

Future<void> main() async {
  EntityReference entity = EntityReference();
  entity.entityId = ENTITY_ID;

  try {
    print("Discovering nodes");
    final gw = await GatewayPool.discover(NETWORK_ID,
        bootnodeUri: BOOTNODES_URL_RW, maxGatewayCount: 5, timeout: 10);

    print("Fetching entity");
    final entityMeta = await fetchEntity(entity, gw);
    print("ENTITY META: ${entityMeta.toString()}");

    print("Fetching process");
    if ((entityMeta.votingProcesses?.active?.length is int) &&
        entityMeta.votingProcesses.active.length > 0) {
      final pid = entityMeta.votingProcesses?.active?.first;
      final processMeta = await getProcessMetadata(pid, gw);
      print("PROCESS META: ${processMeta.toString()}");
    }
  } catch (err) {
    print(err);
  }
}
