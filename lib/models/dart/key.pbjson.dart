///
//  Generated code. Do not modify.
//  source: key.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const Key$json = const {
  '1': 'Key',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.dvote.Key.Type', '10': 'type'},
    const {'1': 'encryptedMnemonic', '3': 2, '4': 1, '5': 9, '10': 'encryptedMnemonic'},
    const {'1': 'encryptedPrivateKey', '3': 3, '4': 1, '5': 9, '10': 'encryptedPrivateKey'},
    const {'1': 'publicKey', '3': 4, '4': 1, '5': 9, '10': 'publicKey'},
    const {'1': 'address', '3': 5, '4': 1, '5': 9, '10': 'address'},
    const {'1': 'meta', '3': 100, '4': 3, '5': 11, '6': '.dvote.Key.MetaEntry', '10': 'meta'},
  ],
  '3': const [Key_MetaEntry$json],
  '4': const [Key_Type$json],
};

const Key_MetaEntry$json = const {
  '1': 'MetaEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const Key_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'SECP256K1', '2': 0},
    const {'1': 'BABYJUB', '2': 1},
  ],
};

