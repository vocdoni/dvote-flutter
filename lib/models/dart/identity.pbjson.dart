///
//  Generated code. Do not modify.
//  source: identity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const IdentitiesStore$json = const {
  '1': 'IdentitiesStore',
  '2': const [
    const {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.dvote.Identity', '10': 'items'},
  ],
};

const Identity$json = const {
  '1': 'Identity',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.dvote.Identity.Type', '10': 'type'},
    const {'1': 'alias', '3': 2, '4': 1, '5': 9, '10': 'alias'},
    const {'1': 'identityId', '3': 3, '4': 1, '5': 9, '10': 'identityId'},
    const {'1': 'keys', '3': 4, '4': 3, '5': 11, '6': '.dvote.Key', '10': 'keys'},
    const {'1': 'peers', '3': 5, '4': 1, '5': 11, '6': '.dvote.Identity.Peers', '10': 'peers'},
    const {'1': 'receivedClaims', '3': 6, '4': 3, '5': 11, '6': '.dvote.Identity.Claim', '10': 'receivedClaims'},
    const {'1': 'issuedClaims', '3': 7, '4': 3, '5': 11, '6': '.dvote.Identity.Claim', '10': 'issuedClaims'},
    const {'1': 'meta', '3': 100, '4': 3, '5': 11, '6': '.dvote.Identity.MetaEntry', '10': 'meta'},
  ],
  '3': const [Identity_Peers$json, Identity_Claim$json, Identity_MetaEntry$json],
  '4': const [Identity_Type$json],
};

const Identity_Peers$json = const {
  '1': 'Peers',
  '2': const [
    const {'1': 'entities', '3': 1, '4': 3, '5': 11, '6': '.dvote.EntityReference', '10': 'entities'},
    const {'1': 'identities', '3': 2, '4': 3, '5': 11, '6': '.dvote.PeerIdentity', '10': 'identities'},
  ],
};

const Identity_Claim$json = const {
  '1': 'Claim',
  '2': const [
    const {'1': 'index', '3': 1, '4': 1, '5': 9, '10': 'index'},
    const {'1': 'proof', '3': 2, '4': 1, '5': 9, '10': 'proof'},
    const {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

const Identity_MetaEntry$json = const {
  '1': 'MetaEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

const Identity_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'ECDSA_SECP256k1', '2': 0},
    const {'1': 'IDEN3', '2': 1},
  ],
};

const PeerIdentity$json = const {
  '1': 'PeerIdentity',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.dvote.PeerIdentity.Type', '10': 'type'},
    const {'1': 'alias', '3': 2, '4': 1, '5': 9, '10': 'alias'},
    const {'1': 'identityId', '3': 3, '4': 1, '5': 9, '10': 'identityId'},
  ],
  '4': const [PeerIdentity_Type$json],
};

const PeerIdentity_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'ECDSA_SECP256k1', '2': 0},
    const {'1': 'IDEN3', '2': 1},
  ],
};

