import 'package:dvote/dvote.dart';
import './constants.dart';

void wallets() {
  try {
    // final wallet = EthereumNativeWallet.random(hdPath: PATH);
    final wallet = EthereumDartWallet.random(hdPath: PATH);
    final mnemonic = wallet.mnemonic;
    final privKey = wallet.privateKey;
    final pubKey = wallet.publicKey;
    final addr = wallet.address;

    print("Wallet info:");
    print("Mnemonic:    $mnemonic");
    print("Priv Key:    $privKey");
    print("Pub Key:     $pubKey");
    print("Address:    $addr");
  } catch (err) {
    print(err);
  }
}
