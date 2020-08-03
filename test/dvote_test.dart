import "./unit/encryption.dart";
import "./unit/wallet.dart";
import "./unit/signature.dart";
import "./unit/metadata.dart";
import "./net/ens.dart";
import "./net/bootnodes.dart";
import "./net/gateway.dart";
import "./integration/entity.dart";
import "./unit/voting.dart";

void main() {
  encryption();
  hdWallet();
  signature();
  dataModels();

  ens();
  bootnodes();
  dvoteGateway();
  web3Gateway();

  entity();
  pollVoting();
}
