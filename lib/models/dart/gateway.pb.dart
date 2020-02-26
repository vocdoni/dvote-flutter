///
//  Generated code. Do not modify.
//  source: gateway.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class BootNodeGateways_NetworkNodes_DVote extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('BootNodeGateways.NetworkNodes.DVote', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'uri')
    ..pPS(2, 'apis')
    ..aOS(3, 'pubKey', protoName: 'pubKey')
    ..hasRequiredFields = false
  ;

  BootNodeGateways_NetworkNodes_DVote._() : super();
  factory BootNodeGateways_NetworkNodes_DVote() => create();
  factory BootNodeGateways_NetworkNodes_DVote.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BootNodeGateways_NetworkNodes_DVote.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  BootNodeGateways_NetworkNodes_DVote clone() => BootNodeGateways_NetworkNodes_DVote()..mergeFromMessage(this);
  BootNodeGateways_NetworkNodes_DVote copyWith(void Function(BootNodeGateways_NetworkNodes_DVote) updates) => super.copyWith((message) => updates(message as BootNodeGateways_NetworkNodes_DVote));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes_DVote create() => BootNodeGateways_NetworkNodes_DVote._();
  BootNodeGateways_NetworkNodes_DVote createEmptyInstance() => create();
  static $pb.PbList<BootNodeGateways_NetworkNodes_DVote> createRepeated() => $pb.PbList<BootNodeGateways_NetworkNodes_DVote>();
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes_DVote getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BootNodeGateways_NetworkNodes_DVote>(create);
  static BootNodeGateways_NetworkNodes_DVote _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get apis => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get pubKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set pubKey($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPubKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPubKey() => clearField(3);
}

class BootNodeGateways_NetworkNodes_Web3 extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('BootNodeGateways.NetworkNodes.Web3', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'uri')
    ..hasRequiredFields = false
  ;

  BootNodeGateways_NetworkNodes_Web3._() : super();
  factory BootNodeGateways_NetworkNodes_Web3() => create();
  factory BootNodeGateways_NetworkNodes_Web3.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BootNodeGateways_NetworkNodes_Web3.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  BootNodeGateways_NetworkNodes_Web3 clone() => BootNodeGateways_NetworkNodes_Web3()..mergeFromMessage(this);
  BootNodeGateways_NetworkNodes_Web3 copyWith(void Function(BootNodeGateways_NetworkNodes_Web3) updates) => super.copyWith((message) => updates(message as BootNodeGateways_NetworkNodes_Web3));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes_Web3 create() => BootNodeGateways_NetworkNodes_Web3._();
  BootNodeGateways_NetworkNodes_Web3 createEmptyInstance() => create();
  static $pb.PbList<BootNodeGateways_NetworkNodes_Web3> createRepeated() => $pb.PbList<BootNodeGateways_NetworkNodes_Web3>();
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes_Web3 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BootNodeGateways_NetworkNodes_Web3>(create);
  static BootNodeGateways_NetworkNodes_Web3 _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uri => $_getSZ(0);
  @$pb.TagNumber(1)
  set uri($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUri() => $_has(0);
  @$pb.TagNumber(1)
  void clearUri() => clearField(1);
}

class BootNodeGateways_NetworkNodes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('BootNodeGateways.NetworkNodes', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..pc<BootNodeGateways_NetworkNodes_DVote>(1, 'dvote', $pb.PbFieldType.PM, subBuilder: BootNodeGateways_NetworkNodes_DVote.create)
    ..pc<BootNodeGateways_NetworkNodes_Web3>(2, 'web3', $pb.PbFieldType.PM, subBuilder: BootNodeGateways_NetworkNodes_Web3.create)
    ..hasRequiredFields = false
  ;

  BootNodeGateways_NetworkNodes._() : super();
  factory BootNodeGateways_NetworkNodes() => create();
  factory BootNodeGateways_NetworkNodes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BootNodeGateways_NetworkNodes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  BootNodeGateways_NetworkNodes clone() => BootNodeGateways_NetworkNodes()..mergeFromMessage(this);
  BootNodeGateways_NetworkNodes copyWith(void Function(BootNodeGateways_NetworkNodes) updates) => super.copyWith((message) => updates(message as BootNodeGateways_NetworkNodes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes create() => BootNodeGateways_NetworkNodes._();
  BootNodeGateways_NetworkNodes createEmptyInstance() => create();
  static $pb.PbList<BootNodeGateways_NetworkNodes> createRepeated() => $pb.PbList<BootNodeGateways_NetworkNodes>();
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways_NetworkNodes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BootNodeGateways_NetworkNodes>(create);
  static BootNodeGateways_NetworkNodes _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<BootNodeGateways_NetworkNodes_DVote> get dvote => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<BootNodeGateways_NetworkNodes_Web3> get web3 => $_getList(1);
}

class BootNodeGateways extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('BootNodeGateways', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOM<BootNodeGateways_NetworkNodes>(1, 'homestead', subBuilder: BootNodeGateways_NetworkNodes.create)
    ..aOM<BootNodeGateways_NetworkNodes>(2, 'goerli', subBuilder: BootNodeGateways_NetworkNodes.create)
    ..m<$core.String, $core.String>(100, 'meta', entryClassName: 'BootNodeGateways.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..hasRequiredFields = false
  ;

  BootNodeGateways._() : super();
  factory BootNodeGateways() => create();
  factory BootNodeGateways.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BootNodeGateways.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  BootNodeGateways clone() => BootNodeGateways()..mergeFromMessage(this);
  BootNodeGateways copyWith(void Function(BootNodeGateways) updates) => super.copyWith((message) => updates(message as BootNodeGateways));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways create() => BootNodeGateways._();
  BootNodeGateways createEmptyInstance() => create();
  static $pb.PbList<BootNodeGateways> createRepeated() => $pb.PbList<BootNodeGateways>();
  @$core.pragma('dart2js:noInline')
  static BootNodeGateways getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BootNodeGateways>(create);
  static BootNodeGateways _defaultInstance;

  @$pb.TagNumber(1)
  BootNodeGateways_NetworkNodes get homestead => $_getN(0);
  @$pb.TagNumber(1)
  set homestead(BootNodeGateways_NetworkNodes v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHomestead() => $_has(0);
  @$pb.TagNumber(1)
  void clearHomestead() => clearField(1);
  @$pb.TagNumber(1)
  BootNodeGateways_NetworkNodes ensureHomestead() => $_ensure(0);

  @$pb.TagNumber(2)
  BootNodeGateways_NetworkNodes get goerli => $_getN(1);
  @$pb.TagNumber(2)
  set goerli(BootNodeGateways_NetworkNodes v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasGoerli() => $_has(1);
  @$pb.TagNumber(2)
  void clearGoerli() => clearField(2);
  @$pb.TagNumber(2)
  BootNodeGateways_NetworkNodes ensureGoerli() => $_ensure(1);

  @$pb.TagNumber(100)
  $core.Map<$core.String, $core.String> get meta => $_getMap(2);
}

class GatewayInfoStore extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GatewayInfoStore', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..pc<GatewayInfo>(1, 'items', $pb.PbFieldType.PM, subBuilder: GatewayInfo.create)
    ..hasRequiredFields = false
  ;

  GatewayInfoStore._() : super();
  factory GatewayInfoStore() => create();
  factory GatewayInfoStore.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GatewayInfoStore.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GatewayInfoStore clone() => GatewayInfoStore()..mergeFromMessage(this);
  GatewayInfoStore copyWith(void Function(GatewayInfoStore) updates) => super.copyWith((message) => updates(message as GatewayInfoStore));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GatewayInfoStore create() => GatewayInfoStore._();
  GatewayInfoStore createEmptyInstance() => create();
  static $pb.PbList<GatewayInfoStore> createRepeated() => $pb.PbList<GatewayInfoStore>();
  @$core.pragma('dart2js:noInline')
  static GatewayInfoStore getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GatewayInfoStore>(create);
  static GatewayInfoStore _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GatewayInfo> get items => $_getList(0);
}

class GatewayInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GatewayInfo', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'dvote')
    ..pPS(2, 'supportedApis', protoName: 'supportedApis')
    ..aOS(3, 'web3')
    ..aOS(4, 'networkId', protoName: 'networkId')
    ..aOS(5, 'publicKey', protoName: 'publicKey')
    ..m<$core.String, $core.String>(100, 'meta', entryClassName: 'GatewayInfo.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..hasRequiredFields = false
  ;

  GatewayInfo._() : super();
  factory GatewayInfo() => create();
  factory GatewayInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GatewayInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GatewayInfo clone() => GatewayInfo()..mergeFromMessage(this);
  GatewayInfo copyWith(void Function(GatewayInfo) updates) => super.copyWith((message) => updates(message as GatewayInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GatewayInfo create() => GatewayInfo._();
  GatewayInfo createEmptyInstance() => create();
  static $pb.PbList<GatewayInfo> createRepeated() => $pb.PbList<GatewayInfo>();
  @$core.pragma('dart2js:noInline')
  static GatewayInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GatewayInfo>(create);
  static GatewayInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dvote => $_getSZ(0);
  @$pb.TagNumber(1)
  set dvote($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDvote() => $_has(0);
  @$pb.TagNumber(1)
  void clearDvote() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get supportedApis => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get web3 => $_getSZ(2);
  @$pb.TagNumber(3)
  set web3($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWeb3() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeb3() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get networkId => $_getSZ(3);
  @$pb.TagNumber(4)
  set networkId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNetworkId() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetworkId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get publicKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set publicKey($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPublicKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearPublicKey() => clearField(5);

  @$pb.TagNumber(100)
  $core.Map<$core.String, $core.String> get meta => $_getMap(5);
}

