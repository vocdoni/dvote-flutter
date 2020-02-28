import 'package:dvote/dvote.dart';

Future<void> hashing() async {
  try {
    final publicKey =
        "0x049a7df67f79246283fdc93af76d4f8cdd62c4886e8cd870944e817dd0b97934fdd7719d0810951e03418205868a5c1b40b192451367f28e0088dd75e15de40c05";

    final hexHash = await poseidonHash(publicKey);
    print("ORIGINAL CLAIM:   $publicKey");
    print("HASHED CLAIM:     $hexHash");
  } catch (err) {
    print(err);
  }
}
