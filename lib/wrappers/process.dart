import 'package:flutter/foundation.dart';

// WRAPPERS AND ENUM'S

/// Wrapper class to enumerate and handle valid values of a process mode
class ProcessMode {
  final int value;
  ProcessMode(this.value) {
    const allFlags = ProcessMode.AUTO_START |
        ProcessMode.INTERRUPTIBLE |
        ProcessMode.DYNAMIC_CENSUS |
        ProcessMode.ALLOW_VOTE_OVERWRITE |
        ProcessMode.ENCRYPTED_METADATA;
    if (value > allFlags || value < 0) throw Exception("Invalid process mode");
  }

  /// By default, the process is started on demand (PAUSED). If set, the process will sIf set, the process will work like `status=PAUSED` before `startBlock` and like `status=ENDED` after `startBlock + blockCount`. The process works on demand, by default.tart as READY and the Vochain will allow incoming votes after `startBlock`
  static const AUTO_START = 1 << 0;

  /// By default, the process can't be paused, ended or canceled. If set, the process can be paused, ended or canceled by the creator.
  static const INTERRUPTIBLE = 1 << 1;

  /// By default, the census is immutable. When set, the creator can update the census while the process remains `READY` or `PAUSED`.
  static const DYNAMIC_CENSUS = 1 << 2;

  /// By default, the first valid vote is final. If set, users will be allowed to vote up to `maxVoteOverwrites` times and the last valid vote will be counted.
  static const ALLOW_VOTE_OVERWRITE = 1 << 3;

  /// By default, the metadata is not encrypted. If set, clients should fetch the decryption key before trying to display the metadata.
  static const ENCRYPTED_METADATA = 1 << 4;

  /// Returns the value that represents the given process mode
  static int make(
      {bool autoStart,
      bool interruptible,
      bool dynamicCensus,
      bool allowVoteOverwrite,
      bool encryptedMetadata}) {
    int result = 0;
    result |= autoStart == true ? ProcessMode.AUTO_START : 0;
    result |= interruptible == true ? ProcessMode.INTERRUPTIBLE : 0;
    result |= dynamicCensus == true ? ProcessMode.DYNAMIC_CENSUS : 0;
    result |= allowVoteOverwrite == true ? ProcessMode.ALLOW_VOTE_OVERWRITE : 0;
    result |= encryptedMetadata == true ? ProcessMode.ENCRYPTED_METADATA : 0;
    return result;
  }

  /// Returns true if the Vochain will not allow votes until `startBlock`.
  bool get isAutoStart {
    return (this.value & ProcessMode.AUTO_START) != 0;
  }

  /// Returns true if the process can be paused, ended and canceled by the creator.
  bool get isInterruptible {
    return (this.value & ProcessMode.INTERRUPTIBLE) != 0;
  }

  /// Returns true if the census can be updated by the creator.
  bool get hasDynamicCensus {
    return (this.value & ProcessMode.DYNAMIC_CENSUS) != 0;
  }

  /// Returns true if voters can overwrite their last vote.
  bool get allowsVoteOverwrite {
    return (this.value & ProcessMode.ALLOW_VOTE_OVERWRITE) != 0;
  }

  /// Returns true if the process metadata is expected to be encrypted.
  bool get hasEncryptedMetadata {
    return (this.value & ProcessMode.ENCRYPTED_METADATA) != 0;
  }
}

/// Wrapper class to enumerate and handle valid values of a process envelope type
class ProcessEnvelopeType {
  final int value;
  ProcessEnvelopeType(this.value) {
    const allFlags = ProcessEnvelopeType.SERIAL |
        ProcessEnvelopeType.ANONYMOUS |
        ProcessEnvelopeType.ENCRYPTED_VOTES;
    if (this.value > allFlags || this.value < 0)
      throw Exception("Invalid envelope type");
  }

  /// By default, all votes are sent within a single envelope. When set, the process questions are voted one by one (enables `questionIndex`).
  static const SERIAL = 1 << 0;

  /// By default, the franchise proof relies on an ECDSA signature (this could reveal the voter's identity). When set, the franchise proof will use ZK-Snarks.
  static const ANONYMOUS = 1 << 1;

  /// By default, votes are sent unencrypted. When the flag is set, votes are sent encrypted and become public when the process ends.
  static const ENCRYPTED_VOTES = 1 << 2;

  /// Returns the value that represents the given envelope type
  static int make({bool serial, bool anonymousVoters, bool encryptedVotes}) {
    int result = 0;
    result |= serial ? ProcessEnvelopeType.SERIAL : 0;
    result |= anonymousVoters ? ProcessEnvelopeType.ANONYMOUS : 0;
    result |= encryptedVotes ? ProcessEnvelopeType.ENCRYPTED_VOTES : 0;
    return result;
  }

  /// Returns true if the process expects one envelope to be sent for each question.
  bool get hasSerialVoting {
    return (this.value & ProcessEnvelopeType.SERIAL) != 0;
  }

  /// Returns true if franchise proofs use ZK-Snarks.
  bool get hasAnonymousVoters {
    return (this.value & ProcessEnvelopeType.ANONYMOUS) != 0;
  }

  /// Returns true if envelopes are to be sent encrypted.
  bool get hasEncryptedVotes {
    return (this.value & ProcessEnvelopeType.ENCRYPTED_VOTES) != 0;
  }
}

/// Wrapper class to enumerate and handle valid values of a process status
class ProcessStatus {
  final int value;
  ProcessStatus(this.value) {
    if (processStatusValues.indexOf(this.value) < 0)
      throw Exception("Invalid status");
  }

  /// The process is ready to accept votes, according to `AUTO_START`, `startBlock` and `blockCount`.
  static const READY = 0;

  /// The creator has ended the process and the results will be available soon.
  static const ENDED = 1;

  /// The process has been canceled. Results will not be available anytime.
  static const CANCELED = 2;

  /// The process is temporarily paused and votes are not accepted at the time. It might be resumed in the future.
  static const PAUSED = 3;

  /// The process is ended and its results are available.
  static const RESULTS = 4;

  bool get isReady {
    return this.value == ProcessStatus.READY;
  }

  bool get isEnded {
    return this.value == ProcessStatus.ENDED;
  }

  bool get isCanceled {
    return this.value == ProcessStatus.CANCELED;
  }

  bool get isPaused {
    return this.value == ProcessStatus.PAUSED;
  }

  bool get hasResults {
    return this.value == ProcessStatus.RESULTS;
  }
}

final processStatusValues = [
  ProcessStatus.READY,
  ProcessStatus.ENDED,
  ProcessStatus.CANCELED,
  ProcessStatus.PAUSED,
  ProcessStatus.RESULTS
];

/// Wraps and unwraps the parameters sent to `Process.newProcess()` and obtained from `Process.get()`
class ProcessParams {
  ProcessMode mode;
  ProcessEnvelopeType envelopeType;
  String entityAddress;
  int startBlock;
  int blockCount;
  String metadata;
  String censusMerkleRoot;
  String censusMerkleTree;
  ProcessStatus status;
  int questionIndex;
  int questionCount;
  int maxCount;
  int maxValue;
  int maxVoteOverwrites;
  bool uniqueValues;
  int maxTotalCost;
  int costExponent;
  int namespace;
  String paramsSignature;
  String results;

  ProcessParams.fromParams(
      {@required int mode,
      @required int envelopeType,
      @required this.entityAddress,
      @required this.metadata,
      @required this.censusMerkleRoot,
      @required this.censusMerkleTree,
      @required this.startBlock,
      @required this.blockCount,
      int status,
      this.questionIndex,
      @required this.questionCount,
      @required this.maxCount,
      @required this.maxValue,
      @required this.maxVoteOverwrites,
      @required this.uniqueValues,
      @required this.maxTotalCost,
      @required this.costExponent,
      @required this.namespace,
      @required this.paramsSignature,
      @required this.results}) {
    // Integrity checks
    if (!RegExp(r"^0x[0-9a-fA-F]{40}$").hasMatch(entityAddress))
      throw Exception("Invalid address");
    else if (metadata.length == 0)
      throw Exception("Invalid metadata");
    else if (censusMerkleRoot.length == 0)
      throw Exception("Invalid censusMerkleRoot");
    else if (censusMerkleTree.length == 0)
      throw Exception("Invalid censusMerkleTree");
    else if (questionCount < 1 || questionCount > 255)
      throw Exception("Invalid questionCount");
    else if (maxCount < 1 || maxCount > 255)
      throw Exception("Invalid maxCount");
    else if (maxValue < 1 || maxValue > 255)
      throw Exception("Invalid maxValue");
    else if (maxVoteOverwrites < 0 || maxVoteOverwrites > 255)
      throw Exception("Invalid maxVoteOverwrites");
    // uniqueValues
    else if (maxTotalCost < 0 || maxTotalCost > 65355)
      throw Exception("Invalid maxTotalCost");
    else if (costExponent < 0 || costExponent > 65355)
      throw Exception("Invalid costExponent");
    else if (namespace < 0 || namespace > 65355)
      throw Exception("Invalid namespace");
    else if (paramsSignature.length == 0)
      throw Exception("Invalid paramsSignature");
    else if (results.length == 0) throw Exception("Invalid results");

    // Direct assignations
    // Fail on error
    this.mode = ProcessMode(mode);
    this.envelopeType = ProcessEnvelopeType(envelopeType);
    if (status is int) this.status = ProcessStatus(status);
  }

  ProcessParams.fromContract(List<dynamic> params) {
    if (!(params is List) || params.length != 9)
      throw Exception("Invalid parameters list");
    else if (!(params[0] is List) ||
        params[0].length != 2 ||
        params[0].any((item) => !(item is int)))
      throw Exception("Invalid parameters mode_envelopeType list");

    mode = ProcessMode(params[0][0]);
    envelopeType = ProcessEnvelopeType(params[0][1]);

    if (!(params[1] is String)) throw Exception("Invalid entityAddress");
    entityAddress = params[1];

    if (!(params[2] is List) ||
        params[2].length != 3 ||
        params[2].any((item) => !(item is String)))
      throw Exception(
          "Invalid parameters metadata_censusMerkleRoot_censusMerkleTree list");
    metadata = params[2][0];
    censusMerkleRoot = params[2][1];
    censusMerkleTree = params[2][2];

    if (!(params[3] is BigInt || params[3] is int))
      throw Exception("Invalid startBlock");
    startBlock = params[3];

    if (!(params[4] is int)) throw Exception("Invalid blockCount");
    blockCount = params[4];

    if (!(params[5] is int)) throw Exception("Invalid status");
    status = ProcessStatus(params[5]);

    if (!(params[6] is List) ||
        params[6].length != 5 ||
        params[6].any((item) => !(item is int)))
      throw Exception(
          "Invalid parameters questionIndex_questionCount_maxCount_maxValue_maxVoteOverwrites list");
    questionIndex = params[6][0];
    questionCount = params[6][1];
    maxCount = params[6][2];
    maxValue = params[6][3];
    maxVoteOverwrites = params[6][4];

    if (!(params[7] is bool)) throw Exception("Invalid uniqueParams");
    uniqueValues = params[7];

    if (!(params[8] is List) ||
        params[8].length != 3 ||
        params[8].any((item) => !(item is int)))
      throw Exception(
          "Invalid parameters maxTotalCost_costExponent_namespace list");

    maxTotalCost = params[8][0];
    costExponent = params[8][1];
    namespace = params[8][2];
  }

  List<dynamic> toContractParams() {
    return [
      [mode.value, envelopeType.value], // int mode_envelopeType
      [
        metadata,
        censusMerkleRoot,
        censusMerkleTree
      ], // String metadata_censusMerkleRoot_censusMerkleTree
      startBlock, // BigNumber startBlock
      blockCount, // int blockCount
      [
        questionCount,
        maxCount,
        maxValue,
        maxVoteOverwrites
      ], // int questionCount_maxCount_maxValue_maxVoteOverwrites
      uniqueValues, // bool uniqueValues
      [maxTotalCost, costExponent], // int maxTotalCost_costExponent
      namespace, // int namespace
      paramsSignature // String paramsSignature
    ];
  }
}

class ProcessKey {
  int idx;
  String key;
}

class ProcessKeys {
  List<ProcessKey> encryptionPubKeys = <ProcessKey>[];
  List<ProcessKey> encryptionPrivKeys = <ProcessKey>[];
  List<ProcessKey> commitmentKeys = <ProcessKey>[];
  List<ProcessKey> revealKeys = <ProcessKey>[];
}
