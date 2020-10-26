import 'package:uuid/uuid.dart';

import 'package:dvote/dvote.dart';
import './constants.dart';

import 'constants.dart';

Future<void> main() async {
  DVoteGateway dvoteGw;
  EntityReference entity = EntityReference();
  entity.entityId = ENTITY_ID;
  entity.entryPoints.addAll(["https://rpc.slock.it/goerli"]);
  const String RESISTRY_URL = "ws://manager.dev.vocdoni.net/api/registry";

  try {
    var uuid = Uuid();
    dvoteGw = DVoteGateway(RESISTRY_URL);
    final wallet = EthereumWallet.random(hdPath: "m/44'/60'/0'/0/5");
    // final wallet = EthereumWallet.random(hdPath: "m/44'/60'/0'/0/5");

    var token = uuid.v4();
    Map<String, dynamic> reply = await validateRegistrationToken(
        ENTITY_ID, token, dvoteGw, wallet.privateKey);
    print(reply);
  } catch (err) {
    print(err);
  }
}
