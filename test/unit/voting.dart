import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:dvote/models/build/dart/common/vote.pb.dart';
import 'package:dvote/util/parsers.dart';
import 'package:dvote/wrappers/process-keys.dart';
import 'package:dvote/wrappers/process-results.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dvote/dvote.dart';
import 'package:dvote_crypto/dvote_crypto.dart';
import 'package:web3dart/credentials.dart';

// import '../../lib/dvote.dart';

void resultsParse() {
  void testProcessResults(String fakeResponse, String state, String type,
      List<List<String>> expectedResults) {
    final Map<String, dynamic> decodedMessage = jsonDecode(fakeResponse);
    final results = parseProcessResults(decodedMessage);
    expect(results.type, type);
    expect(results.state, state);
    expect(results.results, expectedResults);
  }

  void testProcessResultsDigestMultipleQuestion(ProcessMetadata fakeMetadata,
      ProcessResults fakeResults, ProcessData fakeData) {
    final resultsDigested = parseProcessResultsDigestedMultiQuestion(
        fakeResults, fakeMetadata, fakeData);
    expect(resultsDigested.type, fakeResults.type);
    expect(resultsDigested.state, fakeResults.state);
    expect(resultsDigested.questions.length, fakeMetadata.questions.length);

    for (int i = 0; i < resultsDigested.questions.length; i++) {
      for (int j = 0; j < fakeMetadata.questions[i].choices.length; j++) {
        expect(resultsDigested.questions[i].voteResults[j].title["default"],
            fakeMetadata.questions[i].choices[j].title["default"]);
        expect(resultsDigested.questions[i].voteResults[j].votes.toString(),
            fakeResults.results[i][j]);
      }
    }
  }

  void testProcessResultsDigestMultipleChoice(ProcessMetadata fakeMetadata,
      ProcessResults fakeResults, ProcessData fakeData) {
    final resultsDigested = parseProcessResultsDigestedMultiQuestion(
        fakeResults, fakeMetadata, fakeData);
    expect(resultsDigested.type, fakeResults.type);
    expect(resultsDigested.state, fakeResults.state);
    expect(resultsDigested.questions.length, fakeMetadata.questions.length);

    for (int i = 0; i < resultsDigested.questions.length; i++) {
      for (int j = 0; j < fakeMetadata.questions[i].choices.length; j++) {
        expect(resultsDigested.questions[i].voteResults[j].title["default"],
            fakeMetadata.questions[i].choices[j].title["default"]);
        expect(resultsDigested.questions[i].voteResults[j].votes.toString(),
            fakeResults.results[i][j]);
      }
    }
  }

  test("Process Results: Simple poll nullifier", () async {
    String address = "424797Ed6d902E17b9180BFcEF452658e148e0Ab";

    String processId =
        "74394b43b2d3f1c4df79fe5a4a67d07cfdab053f586253286d515d36e89db3e7";

    final nullifier1 = await getSignedVoteNullifier(address, processId);
    expect(nullifier1,
        "0x1b131b6f4e099ebb77b5886f606f5f9af1f20837c45945482e0af2b1df46fe86");
  });

  // test("Should retrieve a valid merkle proof if the user is eligible to vote in an election");
  test("Process Results: Should compute valid poll nullifiers", () async {
    final processId =
        "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1";
    var wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");
    expect(wallet.privateKey,
        "0xdc44bf8c260abe06a7265c5775ea4fb68ecd1b1940cfa76c1726141ec0da5ddc");
    expect(wallet.address, "0xaDDAa28Fb1fe87362A6dFdC9d3EEA03d0C221d81");

    String nullifier = await getSignedVoteNullifier(wallet.address, processId);
    expect(nullifier,
        "0xf6e3fe2d68f3ccc3af2a7835b302e42c257e2de6539c264542f11e5588e8c162");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/0");
    nullifier = await getSignedVoteNullifier(wallet.address, processId);
    expect(nullifier,
        "0x13bf966813b5299110d34b1e565d62d8c26ecb1f76f92ca8bd21fd91600360bc");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/2");
    nullifier = await getSignedVoteNullifier(wallet.address, processId);
    expect(nullifier,
        "0x25e1ec205509664e2433b9f9930c901eb1f2e31e851468a6ef7329dd9ada3bc8");

    wallet = EthereumWallet.fromMnemonic(
        "myth like bonus scare over problem client lizard pioneer submit female collect",
        hdPath: "m/44'/60'/0'/0/3");
    nullifier = await getSignedVoteNullifier(wallet.address, processId);
    expect(nullifier,
        "0x419761e28c5103fa4ddac3d575a940c683aa647c31a8ac1073c8780f4664efcb");
  });

  test("Process Results: Should parse valid process results", () {
    final fakeResponse0 =
        '{"height":2,"ok":true,"request":"ZH61xq6LE3NAe73Ds5KB9A==","results":[["2"]],"state":"canceled","timestamp":1600785127,"type":"poll-vote"}';
    final fakeResponse1 =
        '{"height":200,"ok":true,"request":"abcdefghijk==","results":[["0", "1", "2", "3"], ["22"], ["342", "0", "1"]],"state":"active","timestamp":1600785127,"type":"poll-vote"}';
    final fakeResponse2 =
        '{"height":1,"ok":true,"request":"33333333333==","results":[["2", "1", "3", "4", "5", "6", "45", "4", "3", "2", "2", "3", "3"]],"state":"ended","timestamp":1600785127,"type":"encrypted-poll"}';
    final List<List<String>> expectedResults0 = [
      ["2"]
    ];
    final List<List<String>> expectedResults1 = [
      ["0", "1", "2", "3"],
      ["22"],
      ["342", "0", "1"],
    ];
    final List<List<String>> expectedResults2 = [
      ["2", "1", "3", "4", "5", "6", "45", "4", "3", "2", "2", "3", "3"]
    ];
    testProcessResults(
        fakeResponse0, "canceled", "poll-vote", expectedResults0);
    testProcessResults(fakeResponse1, "active", "poll-vote", expectedResults1);
    testProcessResults(
        fakeResponse2, "ended", "encrypted-poll", expectedResults2);
  });

  test(
      "Process Results Multiquestion: Should parse valid process results digest",
      () async {
    final fakeMetadata0 = ProcessMetadata();
    final fakeData0 = ProcessData.fromJsonString(
        """[["1","0","1"],"0x63c1452cf8f2fed7ead5e6c222c41e96c6ec1e0f",["ipfs://QmVBUKa6xUitCSmf5fnghJUhEXXoY4qjW79LkUntpwDY9s","0x0000000000000000000000000000000000000000000000000000000000000000","ipfs://1234"],["14500","100"],"0",["0","2","1","5","1"],["0","1000","1"],"0"]""");
    final fakeResults0 = ProcessResults.empty();
    List<ProcessMetadata_Question> questions = List<ProcessMetadata_Question>();
    fakeResults0.type = "poll-vote";
    fakeResults0.state = "ended";
    fakeResults0.results = List<List<String>>();
    for (int i = 0; i < 10; i++) {
      final question = ProcessMetadata_Question();
      question.title.addAll({"default": "Question " + i.toString()});
      question.description.addAll({"default": "Description " + i.toString()});
      fakeResults0.results.add([]);
      final options = List<ProcessMetadata_Question_VoteOption>();
      for (int j = 0; j < 3; j++) {
        final option = ProcessMetadata_Question_VoteOption();
        option.title.addAll({"default": "Yes" + i.toString()});
        option.title.addAll({"default": "No" + i.toString()});
        option.value = i;
        options.add(option);
        fakeResults0.results[i].add(j.toString());
      }
      question.choices.addAll(options);
      questions.add(question);
    }
    fakeMetadata0.questions.addAll(questions);

    final fakeMetadata1 = fakeMetadata0;
    final fakeData1 = fakeData0;
    final fakeResults1 = fakeResults0;
    // Test for metadata with no results yet
    fakeResults1.results.forEach((element) {
      element = [];
    });

    testProcessResultsDigestMultipleQuestion(
        fakeMetadata0, fakeResults0, fakeData0);
    testProcessResultsDigestMultipleQuestion(
        fakeMetadata1, fakeResults1, fakeData1);
  });

  test(
      "Process Results Multiple Choice: Should parse valid process results digest",
      () async {
    final fakeMetadata0 = ProcessMetadata();
    final fakeData0 = ProcessData.fromJsonString(
        """[[3, 0, 1], 0xa76737456a15f1c700ece7d46593262d0caa4ec1, [ipfs://QmehryA5Y8itsSWt6fQtPaSCySJn4a2kz7xV7mj9ndyyou, bb0c58b6875208e754a890068cdb9e48f1728b2e7a5308d0633b0a32717f08d9, ipfs://Qmb7chRHogULWt6G8uBF9ZP8hcJMhBJaEYXTn4i9eoWgP2], [147814, 25087], 0, [0, 2, 2, 6, 0], [0, 1, 0], 0]""");
    final fakeResults0 = ProcessResults.empty();
    List<ProcessMetadata_Question> questions = List<ProcessMetadata_Question>();
    fakeResults0.type = "poll-vote";
    fakeResults0.state = "ended";
    fakeResults0.results = List<List<String>>();
    final question = ProcessMetadata_Question();
    question.title.addAll({"default": "Multi question"});
    question.description
        .addAll({"default": "Do we like multi question voting?"});
    fakeResults0.results.add([]);
    final options = List<ProcessMetadata_Question_VoteOption>();
    for (int j = 0; j < 3; j++) {
      final option = ProcessMetadata_Question_VoteOption();
      option.title.addAll({"default": "Option " + j.toString()});
      option.value = j;
      options.add(option);
      fakeResults0.results[0].add(Random().nextInt(10).toString());
    }
    question.choices.addAll(options);
    questions.add(question);
    fakeMetadata0.questions.addAll(questions);

    final fakeMetadata1 = fakeMetadata0;
    final fakeData1 = fakeData0;
    final fakeResults1 = fakeResults0;
    // Test for metadata with no results yet
    fakeResults1.results.forEach((element) {
      element = [];
    });

    testProcessResultsDigestMultipleChoice(
        fakeMetadata0, fakeResults0, fakeData0);
    testProcessResultsDigestMultipleChoice(
        fakeMetadata1, fakeResults1, fakeData1);
  });
}

void flagsParse() {
  void testProcessEnvelopeType() {
    final def = ProcessEnvelopeType(0);
    final all = ProcessEnvelopeType.make(
        serial: true, anonymous: true, encrypted: true, uniqueValues: true);
    final none = ProcessEnvelopeType.make(
        serial: false, anonymous: false, encrypted: false, uniqueValues: false);
    final some = ProcessEnvelopeType.make(
        anonymous: true, encrypted: false, uniqueValues: true);

    test("Parse Process Flags: Should create and decode process envelope types",
        () async {
      expect(def.hasSerialVoting, false);
      expect(all.hasSerialVoting, true);
      expect(none.hasSerialVoting, false);
      expect(some.hasSerialVoting, false);

      expect(def.hasAnonymousVoters, false);
      expect(all.hasAnonymousVoters, true);
      expect(none.hasAnonymousVoters, false);
      expect(some.hasAnonymousVoters, true);

      expect(def.hasEncryptedVotes, false);
      expect(all.hasEncryptedVotes, true);
      expect(none.hasEncryptedVotes, false);
      expect(some.hasEncryptedVotes, false);

      expect(def.hasUniqueValues, false);
      expect(all.hasUniqueValues, true);
      expect(none.hasUniqueValues, false);
      expect(some.hasUniqueValues, true);
    });
  }

  void testProcessMode() {
    final def = ProcessMode(0);
    final all = ProcessMode.make(
        autoStart: true,
        interruptible: true,
        dynamicCensus: true,
        encryptedMetadata: true);
    final none = ProcessMode.make(
        autoStart: false,
        interruptible: false,
        dynamicCensus: false,
        encryptedMetadata: false);
    final some = ProcessMode.make(
        autoStart: true, dynamicCensus: true, encryptedMetadata: true);

    test("Parse Process Flags: Should create and decode process modes",
        () async {
      expect(def.isAutoStart, false);
      expect(all.isAutoStart, true);
      expect(none.isAutoStart, false);
      expect(some.isAutoStart, true);

      expect(def.isInterruptible, false);
      expect(all.isInterruptible, true);
      expect(none.isInterruptible, false);
      expect(some.isInterruptible, false);

      expect(def.hasDynamicCensus, false);
      expect(all.hasDynamicCensus, true);
      expect(none.hasDynamicCensus, false);
      expect(some.hasDynamicCensus, true);

      expect(def.hasEncryptedMetadata, false);
      expect(all.hasEncryptedMetadata, true);
      expect(none.hasEncryptedMetadata, false);
      expect(some.hasEncryptedMetadata, true);
    });
  }

  void testProcessStatus() {
    test("Parse Process Flags: Should create and decode process statuses",
        () async {
      // Positive cases
      expect(ProcessStatus(ProcessStatus.READY).isReady, true);
      expect(ProcessStatus(ProcessStatus.ENDED).isEnded, true);
      expect(ProcessStatus(ProcessStatus.CANCELED).isCanceled, true);
      expect(ProcessStatus(ProcessStatus.PAUSED).isPaused, true);
      expect(ProcessStatus(ProcessStatus.RESULTS).hasResults, true);

      // Negative cases
      expect(ProcessStatus(ProcessStatus.RESULTS).isReady, false);
      expect(ProcessStatus(ProcessStatus.READY).isEnded, false);
      expect(ProcessStatus(ProcessStatus.ENDED).isCanceled, false);
      expect(ProcessStatus(ProcessStatus.CANCELED).isPaused, false);
      expect(ProcessStatus(ProcessStatus.PAUSED).hasResults, false);
    });
  }

  void testSingleProcessData(
      {int mode = 0,
      int envelopeType = 0,
      int censusOrigin = 1,
      EthereumAddress entityAddress,
      String metadata = "",
      String censusRoot = "",
      String censusUri = "",
      int startBlock = 0,
      int blockCount = 0,
      int status = 0,
      int questionIndex = 0,
      int questionCount = 0,
      int maxCount = 0,
      int maxValue = 0,
      int maxVoteOverwrites = 0,
      int maxTotalCost = 0,
      int costExponent = 0,
      int namespace = 0,
      int evmBlockHeight = 0}) {
    if (entityAddress == null)
      entityAddress =
          EthereumAddress.fromHex("0x0000000000000000000000000000000000000000");
    final testData = ProcessData([
      [BigInt.from(mode), BigInt.from(envelopeType), BigInt.from(censusOrigin)],
      entityAddress,
      [metadata, censusRoot, censusUri],
      [BigInt.from(startBlock), BigInt.from(blockCount)],
      BigInt.from(status),
      [
        BigInt.from(questionIndex),
        BigInt.from(questionCount),
        BigInt.from(maxCount),
        BigInt.from(maxValue),
        BigInt.from(maxVoteOverwrites)
      ],
      [
        BigInt.from(maxTotalCost),
        BigInt.from(costExponent),
        BigInt.from(namespace)
      ],
      BigInt.from(evmBlockHeight),
    ]);
    expect(testData.getMode.value, mode);
    expect(testData.getEnvelopeType.value, envelopeType);
    expect(testData.getCensusOrigin.value, censusOrigin);
    expect(testData.getEntityAddress, entityAddress);
    expect(testData.getMetadata, metadata);
    expect(testData.getCensusRoot, censusRoot);
    expect(testData.getCensusUri, censusUri);
    expect(testData.getStartBlock, startBlock);
    expect(testData.getBlockCount, blockCount);
    expect(testData.getStatus.value, status);
    expect(testData.getQuestionIndex, questionIndex);
    expect(testData.getQuestionCount, questionCount);
    expect(testData.getMaxCount, maxCount);
    expect(testData.getMaxValue, maxValue);
    expect(testData.getMaxVoteOverwrites, maxVoteOverwrites);
    expect(testData.getMaxTotalCost, maxTotalCost);
    expect(testData.getCostExponent, costExponent);
    expect(testData.getNamespace, namespace);
    expect(
        testData.getEvmBlockHeight.compareTo(BigInt.from(evmBlockHeight)), 0);
  }

  void testProcessData() {
    test("Process Data: Should correctly parse a processData array", () async {
      testSingleProcessData();
      testSingleProcessData(evmBlockHeight: 1);
      testSingleProcessData(
          mode: ProcessMode.make(
                  autoStart: true, interruptible: true, dynamicCensus: true)
              .value,
          envelopeType: ProcessEnvelopeType.make(serial: true).value,
          censusOrigin: 3,
          metadata: "metadata :)",
          censusRoot: "R00t",
          censusUri: "merkle treeee",
          startBlock: 15000,
          blockCount: 200,
          status: ProcessStatus.READY,
          questionIndex: 24,
          questionCount: 30,
          maxCount: 3,
          maxValue: 1,
          maxVoteOverwrites: 1,
          maxTotalCost: 30,
          costExponent: 1,
          namespace: 234239,
          evmBlockHeight: 999999);
    });
  }

  testProcessEnvelopeType();
  testProcessMode();
  testProcessStatus();
  testProcessData();
}

void pollVoting() {
  // NOTE: May not be able to test on pure Dart, given that the code below depends on iOS/Android native targets.
  // TODO: Move this code to the Example app

  test("Poll Voting: Should bundle a Vote Package into a valid Vote Envelope",
      () async {
    final wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");

    String processId =
        "0x8b35e10045faa886bd2e18636cd3cb72e80203a04e568c47205bf0313a0f60d1";
    String siblings =
        "0x0003000000000000000000000000000000000000000000000000000000000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f";

    final envelope1 = await packageSignedEnvelope(
        [1, 2, 3],
        siblings,
        processId,
        wallet.privateKey,
        ProcessCensusOrigin(ProcessCensusOrigin.OFF_CHAIN_TREE));
    final decodedEnvelope1 = VoteEnvelope.fromBuffer(envelope1.envelope);
    expect(hex.encode(decodedEnvelope1.processId),
        processId.replaceFirst("0x", ""));
    expect(hex.encode(decodedEnvelope1.proof.graviton.siblings),
        siblings.replaceFirst("0x", ""));

    final pkg1 =
        utf8.decode(decodedEnvelope1.votePackage, allowMalformed: true);
    Map<String, dynamic> decodedVotePkg1;
    if (pkg1 is String) decodedVotePkg1 = jsonDecode(pkg1);
    expect(decodedVotePkg1["votes"].length, 3);
    expect(decodedVotePkg1["votes"][0], 1);
    expect(decodedVotePkg1["votes"][1], 2);
    expect(decodedVotePkg1["votes"][2], 3);

    processId =
        "0x36c886bd2e18605bf03a0428be100313a0f6e568c470d135d3cb72e802045faa";
    siblings =
        "0x0003000000100000000002000000000300000000000400000000000050000006f0d72fbd8b3a637488107b0d8055410180ec017a4d76dbb97bee1c3086a25e25b1a6134dbd323c420d6fc2ac3aaf8fff5f9ac5bc0be5949be64b7cfd1bcc5f1f";

    final envelope2 = await packageSignedEnvelope(
        [4, 5, 6],
        siblings,
        processId,
        wallet.privateKey,
        ProcessCensusOrigin(ProcessCensusOrigin.OFF_CHAIN_TREE));
    final decodedEnvelope2 = VoteEnvelope.fromBuffer(envelope2.envelope);
    expect(
        hex.encode(decodedEnvelope2.processId), processId.replaceAll("0x", ""));
    expect(hex.encode(decodedEnvelope2.proof.graviton.siblings),
        siblings.replaceFirst("0x", ""));

    final pkg2 =
        utf8.decode(decodedEnvelope2.votePackage, allowMalformed: true);
    Map<String, dynamic> decodedVotePkg2;
    if (pkg1 is String) decodedVotePkg2 = jsonDecode(pkg2);
    expect(decodedVotePkg2["votes"].length, 3);
    expect(decodedVotePkg2["votes"][0], 4);
    expect(decodedVotePkg2["votes"][1], 5);
    expect(decodedVotePkg2["votes"][2], 6);
  });

  test(
      "Poll Voting: Should bundle an encrypted Vote Package into a valid Vote Envelope",
      () async {
    final wallet = EthereumWallet.fromMnemonic(
        "seven family better journey display approve crack burden run pattern filter topple");

    final votePrivateKey =
        "91f86dd7a9ac258c4908ca8fbdd3157f84d1f74ffffcb9fa428fba14a1d40150";
    final votePublicKey =
        "6876524df21d6983724a2b032e41471cc9f1772a9418c4d701fcebb6c306af50";

    final List<Map<String, dynamic>> processes = [
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

    //   // one key;
    for (var item in processes) {
      ProcessKeys processKeys = ProcessKeys();
      ProcessKey entry = ProcessKey();
      entry.idx = 0;
      entry.key = votePublicKey;
      processKeys.encryptionPubKeys = [entry];
      final envelope = await packageSignedEnvelope(
          item["votes"],
          item["siblings"],
          item["processId"],
          wallet.privateKey,
          ProcessCensusOrigin(ProcessCensusOrigin.OFF_CHAIN_TREE),
          processKeys: processKeys);

      final decodedEnvelope = VoteEnvelope.fromBuffer(envelope.envelope);
      expect(hex.encode(decodedEnvelope.processId),
          item["processId"].replaceFirst("0x", ""));
      expect(hex.encode(decodedEnvelope.proof.graviton.siblings),
          item["siblings"].replaceFirst("0x", ""));
      expect(decodedEnvelope.encryptionKeyIndexes.length, 1);
      expect(decodedEnvelope.encryptionKeyIndexes[0], 0);
      expect(decodedEnvelope.votePackage.length > 0, true);

      final pkg = jsonDecode(utf8.decode(
          Asymmetric.decryptRaw(decodedEnvelope.votePackage, votePrivateKey)));
      expect(item["votes"] is List, true);
      expect(pkg["votes"].length, (item["votes"] as List).length);
      expect(pkg["votes"][0], (item["votes"] as List)[0]);
      expect(pkg["votes"][1], (item["votes"] as List)[1]);
      expect(pkg["votes"][2], (item["votes"] as List)[2]);
    }
  });

  test(
      "Poll Voting: Should bundle a Vote Package encrypted with N keys in the right order",
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

    final List<Map<String, dynamic>> processes = [
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

      final envelope = await packageSignedEnvelope(
          item["votes"],
          item["siblings"],
          item["processId"],
          wallet.privateKey,
          ProcessCensusOrigin(ProcessCensusOrigin.OFF_CHAIN_TREE),
          processKeys: processKeys);

      final decodedEnvelope = VoteEnvelope.fromBuffer(envelope.envelope);
      expect(hex.encode(decodedEnvelope.processId),
          item["processId"].replaceFirst("0x", ""));
      expect(hex.encode(decodedEnvelope.proof.graviton.siblings),
          item["siblings"].replaceFirst("0x", ""));
      expect(decodedEnvelope.encryptionKeyIndexes.length, 4);
      expect(decodedEnvelope.encryptionKeyIndexes[0], 0);
      expect(decodedEnvelope.votePackage.length > 0, true);

      Uint8List decrypted;
      // decrypt in reverse order
      for (int i = encryptionKeys.length - 1; i >= 0; i--) {
        if (i < encryptionKeys.length - 1)
          decrypted =
              Asymmetric.decryptRaw(decrypted, encryptionKeys[i]["privateKey"]);
        else
          decrypted = Asymmetric.decryptRaw(
              decodedEnvelope.votePackage, encryptionKeys[i]["privateKey"]);
      }

      final pkg = jsonDecode(utf8.decode(decrypted));

      expect(item["votes"] is List, true);
      expect(pkg["votes"].length, (item["votes"] as List).length);
      expect(pkg["votes"][0], (item["votes"] as List)[0]);
      expect(pkg["votes"][1], (item["votes"] as List)[1]);
      expect(pkg["votes"][2], (item["votes"] as List)[2]);
    }
  });
}
