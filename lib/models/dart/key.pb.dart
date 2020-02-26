///
//  Generated code. Do not modify.
//  source: key.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'key.pbenum.dart';

export 'key.pbenum.dart';

class Key extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Key', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..e<Key_Type>(1, 'type', $pb.PbFieldType.OE, defaultOrMaker: Key_Type.SECP256K1, valueOf: Key_Type.valueOf, enumValues: Key_Type.values)
    ..aOS(2, 'encryptedMnemonic', protoName: 'encryptedMnemonic')
    ..aOS(3, 'encryptedPrivateKey', protoName: 'encryptedPrivateKey')
    ..aOS(4, 'publicKey', protoName: 'publicKey')
    ..aOS(5, 'address')
    ..m<$core.String, $core.String>(100, 'meta', entryClassName: 'Key.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..hasRequiredFields = false
  ;

  Key._() : super();
  factory Key() => create();
  factory Key.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Key.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Key clone() => Key()..mergeFromMessage(this);
  Key copyWith(void Function(Key) updates) => super.copyWith((message) => updates(message as Key));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Key create() => Key._();
  Key createEmptyInstance() => create();
  static $pb.PbList<Key> createRepeated() => $pb.PbList<Key>();
  @$core.pragma('dart2js:noInline')
  static Key getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Key>(create);
  static Key _defaultInstance;

  @$pb.TagNumber(1)
  Key_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(Key_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptedMnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptedMnemonic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptedMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptedMnemonic() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get encryptedPrivateKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set encryptedPrivateKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncryptedPrivateKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncryptedPrivateKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get publicKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicKey($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicKey() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get address => $_getSZ(4);
  @$pb.TagNumber(5)
  set address($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddress() => clearField(5);

  @$pb.TagNumber(100)
  $core.Map<$core.String, $core.String> get meta => $_getMap(5);
}

