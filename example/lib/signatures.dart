import 'package:dvote/dvote.dart';

final messageToSign = "hello";
final privKeyToSign =
    "fad9c8855b740a0b7ed4c221dbad0f33a83a49cad6b3fe8d5817ac83d38b6a19";
final publicKey =
    "0x049a7df67f79246283fdc93af76d4f8cdd62c4886e8cd870944e817dd0b97934fdd7719d0810951e03418205868a5c1b40b192451367f28e0088dd75e15de40c05";

void signatures() {
  try {
    // final signature = SignatureNative.signString(messageToSign, privKeyToSign);
    // final valid =
    //     SignatureNative.isValidSignature(signature, messageToSign, publicKey);

    final signature = SignatureDart.signString(messageToSign, privKeyToSign);
    final valid =
        SignatureDart.isValidSignature(signature, messageToSign, publicKey);

    print("Signed: $messageToSign");
    print("Priv Key: $privKeyToSign");
    print("Pub Key: $publicKey");
    print("Signature: $signature");
    print("Valid: $valid");
  } catch (err) {
    print(err);
  }
}
