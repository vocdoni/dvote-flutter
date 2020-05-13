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
