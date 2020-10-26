import 'package:dvote/dvote.dart';
import './constants.dart';

Future<void> initPlatformState() async {
  String mnemonic, privKey, pubKey, addr;

  try {
    final start = DateTime.now();

    // Native computation
    final wallet = EthereumWallet.random(hdPath: HD_PATH);
    mnemonic = wallet.mnemonic;
    privKey = wallet.privateKey;
    pubKey = wallet.publicKey(uncompressed: false);
    addr = wallet.address;

    final end = DateTime.now();

    print("Mnemonic '$mnemonic'\n");
    print("Private key\n$privKey\n");
    print("Public key\n$pubKey\n");
    print("Address\n$addr\n");

    print("Computation: ${end.difference(start).inMilliseconds}ms");
  } catch (err) {
    print(err);
  }
}
