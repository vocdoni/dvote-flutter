///
//  Generated code. Do not modify.
//  source: identity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Identity_Type extends $pb.ProtobufEnum {
  static const Identity_Type ECDSA_SECP256k1 = Identity_Type._(0, 'ECDSA_SECP256k1');
  static const Identity_Type IDEN3 = Identity_Type._(1, 'IDEN3');

  static const $core.List<Identity_Type> values = <Identity_Type> [
    ECDSA_SECP256k1,
    IDEN3,
  ];

  static final $core.Map<$core.int, Identity_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Identity_Type valueOf($core.int value) => _byValue[value];

  const Identity_Type._($core.int v, $core.String n) : super(v, n);
}

class PeerIdentity_Type extends $pb.ProtobufEnum {
  static const PeerIdentity_Type ECDSA_SECP256k1 = PeerIdentity_Type._(0, 'ECDSA_SECP256k1');
  static const PeerIdentity_Type IDEN3 = PeerIdentity_Type._(1, 'IDEN3');

  static const $core.List<PeerIdentity_Type> values = <PeerIdentity_Type> [
    ECDSA_SECP256k1,
    IDEN3,
  ];

  static final $core.Map<$core.int, PeerIdentity_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PeerIdentity_Type valueOf($core.int value) => _byValue[value];

  const PeerIdentity_Type._($core.int v, $core.String n) : super(v, n);
}

