import 'dart:convert';

import 'package:dvote/wrappers/process-keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';

void pollVoting() {
  test("Simple poll nullifier", () async {
    String address = "424797Ed6d902E17b9180BFcEF452658e148e0Ab";
    String processId =
        "74394b43b2d3f1c4df79fe5a4a67d07cfdab053f586253286d515d36e89db3e7";

    final nullifier1 = await getPollNullifier(address, processId);
    expect(nullifier1,
        "0x1b131b6f4e099ebb77b5886f606f5f9af1f20837c45945482e0af2b1df46fe86");
  });

  // test("Should retrieve a valid merkle proof if the user is eligible to vote in an election");
  test("Should compute valid poll nullifiers", () async {
    final processId =
        "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1";
    var wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");
    expect(wallet.privateKey,
        "0xdc44bf8c260abe06a7265c5775ea4fb68ecd1b1940cfa76c1726141ec0da5ddc");
    expect(wallet.address, "0xaDDAa28Fb1fe87362A6dFdC9d3EEA03d0C221d81");

    String nullifier = await getPollNullifier(wallet.address, processId);
    expect(nullifier,
        "0xf6e3fe2d68f3ccc3af2a7835b302e42c257e2de6539c264542f11e5588e8c162");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/0");
    nullifier = await getPollNullifier(wallet.address, processId);
    expect(nullifier,
        "0x13bf966813b5299110d34b1e565d62d8c26ecb1f76f92ca8bd21fd91600360bc");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/2");
    nullifier = await getPollNullifier(wallet.address, processId);
    expect(nullifier,
        "0x25e1ec205509664e2433b9f9930c901eb1f2e31e851468a6ef7329dd9ada3bc8");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/3");
    nullifier = await getPollNullifier(wallet.address, processId);
    expect(nullifier,
        "0x419761e28c5103fa4ddac3d575a940c683aa647c31a8ac1073c8780f4664efcb");
  });
  test("Should bundle a Vote Package into a valid Vote Envelope", () async {
    final wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");

    String processId =
        "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1";
    String siblings =
        "0x0003000000000000000000000000000000000000000000000000000000000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f";

    final envelope1 = await packagePollEnvelope(
        [1, 2, 3], siblings, processId, wallet.privateKey);
    expect(envelope1["processId"], processId);
    expect(envelope1["proof"], siblings);

    final pkg1 =
        jsonDecode(utf8.decode(base64.decode(envelope1["votePackage"])));
    expect(pkg1["type"], "poll-vote");
    expect(pkg1["votes"].length, 3);
    expect(pkg1["votes"][0], 1);
    expect(pkg1["votes"][1], 2);
    expect(pkg1["votes"][2], 3);

    processId =
        "0x36c886bd2e18605bf03a0428be100313a0f6e568c470d135d3cb72e802045faa";
    siblings =
        "0x0003000000100000000002000000000300000000000400000000000050000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f";

    final envelope2 = await packagePollEnvelope(
        [5, 6, 7], siblings, processId, wallet.privateKey);
    expect(envelope2["processId"], processId);
    expect(envelope2["proof"], siblings);

    final pkg2 =
        jsonDecode(utf8.decode(base64.decode(envelope2["votePackage"])));
    expect(pkg2["type"], "poll-vote");
    expect(pkg2["votes"].length, 3);
    expect(pkg2["votes"][0], 5);
    expect(pkg2["votes"][1], 6);
    expect(pkg2["votes"][2], 7);
  });

  test("Should bundle an encrypted Vote Package into a valid Vote Envelope",
      () async {
    final wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");

    final votePrivateKey =
        "91f86dd7a9ac258c4908ca8fbdd3157f84d1f74ffffcb9fa428fba14a1d40150";
    final votePublicKey =
        "6876524df21d6983724a2b032e41471cc9f1772a9418c4d701fcebb6c306af50";

    final processes = [
      {
        "processId":
            "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1",
        "siblings":
            "0x0003000000000000000000000000000000000000000000000000000000000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [1, 2, 3]
      },
      {
        "processId":
            "0x36c886bd2e18605bf03a0428be100313a0f6e568c470d135d3cb72e802045faa",
        "siblings":
            "0x00030000001000000000020000000003000000000004000000000000500000053cd72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [4, 5, 6]
      },
      {
        "processId":
            "0x21c886bd2e18605b733a0428be100313a057e568c470d135d3cb72e312045faa",
        "siblings":
            "0x00030080001000000080020000400003000003000004000000200000500004053cd72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [7, 8, 9]
      }
    ];

    // one key;
    for (var item in processes) {
      ProcessKeys processKeys = ProcessKeys();
      ProcessKey entry = ProcessKey();
      entry.idx = 0;
      entry.key = votePublicKey;
      processKeys.encryptionPubKeys = [entry];
      final envelope = await packagePollEnvelope(
          item["votes"], item["siblings"], item["processId"], wallet.privateKey,
          processKeys: processKeys);
      expect(envelope["processId"], item["processId"]);
      expect(envelope["proof"], item["siblings"]);
      expect(envelope["encryptionKeyIndexes"].length, 1);
      expect(envelope["encryptionKeyIndexes"][0], 0);
      expect(envelope["votePackage"] is String, true);
      expect(base64.decode(envelope["votePackage"]).length > 0, true);

      final pkg = jsonDecode(
          Asymmetric.decryptString(envelope["votePackage"], votePrivateKey));
      expect(pkg["type"], "poll-vote");
      expect(item["votes"] is List, true);
      expect(pkg["votes"].length, (item["votes"] as List).length);
      expect(pkg["votes"][0], (item["votes"] as List)[0]);
      expect(pkg["votes"][1], (item["votes"] as List)[1]);
      expect(pkg["votes"][2], (item["votes"] as List)[2]);
    }
  });

  test("Should bundle a Vote Package encrypted with N keys in the right order",
      () async {
    final wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");

    final encryptionKeys = [
      {
        "publicKey":
            "2123cee48e684d22e8cc3f4886eac4602df0e31b4260d0f02229f496539e3402",
        "privateKey":
            "0f658e034979483cd24dca2d67a46a58a99d934922e4f08b3cab00648dda9350"
      },
      {
        "publicKey":
            "04b86ffbb39c275aae8515d706f6e866644c7f0a1bdefc74ba778e6a1390ac0d",
        "privateKey":
            "5899a068bc541f9bf56d4b8ae96500d17576e337995797a5c86a0cd1b6f7959b"
      },
      {
        "publicKey":
            "6d8a5cfdc228c7b134f062e67957cc13f89f04900a23525a76a30809d9039a06",
        "privateKey":
            "70c83c76baea242d1003c68e079400028b49b790d6cbbd739aff970313f45d5b"
      },
      {
        "publicKey":
            "90e5f52ce1ec965b8f3a1535b537998687fc6c04400af705f8c4982bca6d6527",
        "privateKey":
            "398f08935e342e86752d5b52163b403e9ebe50ea53a82bdab6014ce9b49e5a44"
      }
    ];

    final processes = [
      {
        "processId":
            "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1",
        "siblings":
            "0x0003000000000000000000000000000000000000000000000000000000000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [10, 20, 30]
      },
      {
        "processId":
            "0x36c886bd2e18605bf03a0428be100313a0f6e568c470d135d3cb72e802045faa",
        "siblings":
            "0x00030000001000000000020000000003000000000004000000000000500000053cd72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [40, 45, 50]
      },
      {
        "processId":
            "0x21c886bd2e18605b733a0428be100313a057e568c470d135d3cb72e312045faa",
        "siblings":
            "0x00030080001000000080020000400003000003000004000000200000500004053cd72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f",
        "votes": [22, 33, 44]
      }
    ];

    // N keys
    for (var item in processes) {
      ProcessKeys processKeys = ProcessKeys();
      int idx = 0;
      processKeys.encryptionPubKeys = encryptionKeys
          .map((k) {
            final result = ProcessKey();
            result.key = k["publicKey"];
            result.idx = idx;
            idx++;
            return result;
          })
          .cast<ProcessKey>()
          .toList();

      final envelope = await packagePollEnvelope(
          item["votes"], item["siblings"], item["processId"], wallet.privateKey,
          processKeys: processKeys);
      expect(envelope["processId"], item["processId"]);
      expect(envelope["proof"], item["siblings"]);
      expect(envelope["encryptionKeyIndexes"].length, 4);
      expect(envelope["encryptionKeyIndexes"][0], 0);
      expect(envelope["encryptionKeyIndexes"][1], 1);
      expect(envelope["encryptionKeyIndexes"][2], 2);
      expect(envelope["encryptionKeyIndexes"][3], 3);
      expect(envelope["votePackage"] is String, true);
      expect(base64.decode(envelope["votePackage"]).length > 0, true);

      String decrypted;
      // decrypt in reverse order
      for (int i = encryptionKeys.length - 1; i >= 0; i--) {
        if (i < encryptionKeys.length - 1)
          decrypted = Asymmetric.decryptString(
              decrypted, encryptionKeys[i]["privateKey"]);
        else
          decrypted = Asymmetric.decryptString(
              envelope["votePackage"], encryptionKeys[i]["privateKey"]);
      }
      final pkg = jsonDecode(decrypted);
      expect(pkg["type"], "poll-vote");
      expect(item["votes"] is List, true);
      expect(pkg["votes"].length, (item["votes"] as List).length);
      expect(pkg["votes"][0], (item["votes"] as List)[0]);
      expect(pkg["votes"][1], (item["votes"] as List)[1]);
      expect(pkg["votes"][2], (item["votes"] as List)[2]);
    }
  });
}
