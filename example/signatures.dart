import 'package:dvote/dvote.dart';

const MESSAGE = "hello";
const PRIVATE_KEY =
    "fad9c8855b740a0b7ed4c221dbad0f33a83a49cad6b3fe8d5817ac83d38b6a19";
const PUBLIC_KEY =
    "0x049a7df67f79246283fdc93af76d4f8cdd62c4886e8cd870944e817dd0b97934fdd7719d0810951e03418205868a5c1b40b192451367f28e0088dd75e15de40c05";

Future<void> main() async {
  String signature, recoveredPubKey;
  bool valid;

  try {
    signature = await Signature.signStringAsync(MESSAGE, PRIVATE_KEY);
    recoveredPubKey =
        await Signature.recoverSignerPubKeyAsync(signature, MESSAGE);
    valid =
        await Signature.isValidSignatureAsync(signature, MESSAGE, PUBLIC_KEY);
  } catch (err) {
    print(err);
    throw err;
  }

  assert(signature == Signature.signString(MESSAGE, PRIVATE_KEY));
  assert(recoveredPubKey == Signature.recoverSignerPubKey(signature, MESSAGE));
  assert(valid == Signature.isValidSignature(signature, MESSAGE, PUBLIC_KEY));

  print("Signing '$MESSAGE'\n");
  print("From private key\n$PRIVATE_KEY\n");
  print("From public key\n$PUBLIC_KEY\n");
  print("Signature\n$signature\n");
  print("Recovered public key (compressed)\n$recoveredPubKey\n");
  print("Valid\n$valid");
}
