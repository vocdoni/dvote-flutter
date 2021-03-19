/// The index and key for a process key
class ProcessKey {
  int idx;
  String key;
}

/// The set of possible keys associated with a process
class ProcessKeys {
  List<ProcessKey> encryptionPubKeys = <ProcessKey>[];
  List<ProcessKey> encryptionPrivKeys = <ProcessKey>[];
  List<ProcessKey> commitmentKeys = <ProcessKey>[];
  List<ProcessKey> revealKeys = <ProcessKey>[];
}
