///
//  Generated code. Do not modify.
//  source: process.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ProcessMetadataStore extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadataStore', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..pc<ProcessMetadata>(1, 'items', $pb.PbFieldType.PM, subBuilder: ProcessMetadata.create)
    ..hasRequiredFields = false
  ;

  ProcessMetadataStore._() : super();
  factory ProcessMetadataStore() => create();
  factory ProcessMetadataStore.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadataStore.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadataStore clone() => ProcessMetadataStore()..mergeFromMessage(this);
  ProcessMetadataStore copyWith(void Function(ProcessMetadataStore) updates) => super.copyWith((message) => updates(message as ProcessMetadataStore));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadataStore create() => ProcessMetadataStore._();
  ProcessMetadataStore createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadataStore> createRepeated() => $pb.PbList<ProcessMetadataStore>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadataStore getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadataStore>(create);
  static ProcessMetadataStore _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ProcessMetadata> get items => $_getList(0);
}

class ProcessMetadata_Census extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadata.Census', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'merkleRoot', protoName: 'merkleRoot')
    ..aOS(2, 'merkleTree', protoName: 'merkleTree')
    ..hasRequiredFields = false
  ;

  ProcessMetadata_Census._() : super();
  factory ProcessMetadata_Census() => create();
  factory ProcessMetadata_Census.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadata_Census.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadata_Census clone() => ProcessMetadata_Census()..mergeFromMessage(this);
  ProcessMetadata_Census copyWith(void Function(ProcessMetadata_Census) updates) => super.copyWith((message) => updates(message as ProcessMetadata_Census));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Census create() => ProcessMetadata_Census._();
  ProcessMetadata_Census createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadata_Census> createRepeated() => $pb.PbList<ProcessMetadata_Census>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Census getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadata_Census>(create);
  static ProcessMetadata_Census _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get merkleRoot => $_getSZ(0);
  @$pb.TagNumber(1)
  set merkleRoot($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMerkleRoot() => $_has(0);
  @$pb.TagNumber(1)
  void clearMerkleRoot() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get merkleTree => $_getSZ(1);
  @$pb.TagNumber(2)
  set merkleTree($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMerkleTree() => $_has(1);
  @$pb.TagNumber(2)
  void clearMerkleTree() => clearField(2);
}

class ProcessMetadata_Details_Question_VoteOption extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadata.Details.Question.VoteOption', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, 'title', entryClassName: 'ProcessMetadata.Details.Question.VoteOption.TitleEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..aOS(2, 'value')
    ..hasRequiredFields = false
  ;

  ProcessMetadata_Details_Question_VoteOption._() : super();
  factory ProcessMetadata_Details_Question_VoteOption() => create();
  factory ProcessMetadata_Details_Question_VoteOption.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadata_Details_Question_VoteOption.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadata_Details_Question_VoteOption clone() => ProcessMetadata_Details_Question_VoteOption()..mergeFromMessage(this);
  ProcessMetadata_Details_Question_VoteOption copyWith(void Function(ProcessMetadata_Details_Question_VoteOption) updates) => super.copyWith((message) => updates(message as ProcessMetadata_Details_Question_VoteOption));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details_Question_VoteOption create() => ProcessMetadata_Details_Question_VoteOption._();
  ProcessMetadata_Details_Question_VoteOption createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadata_Details_Question_VoteOption> createRepeated() => $pb.PbList<ProcessMetadata_Details_Question_VoteOption>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details_Question_VoteOption getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadata_Details_Question_VoteOption>(create);
  static ProcessMetadata_Details_Question_VoteOption _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.String> get title => $_getMap(0);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class ProcessMetadata_Details_Question extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadata.Details.Question', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'type')
    ..m<$core.String, $core.String>(2, 'question', entryClassName: 'ProcessMetadata.Details.Question.QuestionEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..m<$core.String, $core.String>(3, 'description', entryClassName: 'ProcessMetadata.Details.Question.DescriptionEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..pc<ProcessMetadata_Details_Question_VoteOption>(4, 'voteOptions', $pb.PbFieldType.PM, protoName: 'voteOptions', subBuilder: ProcessMetadata_Details_Question_VoteOption.create)
    ..hasRequiredFields = false
  ;

  ProcessMetadata_Details_Question._() : super();
  factory ProcessMetadata_Details_Question() => create();
  factory ProcessMetadata_Details_Question.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadata_Details_Question.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadata_Details_Question clone() => ProcessMetadata_Details_Question()..mergeFromMessage(this);
  ProcessMetadata_Details_Question copyWith(void Function(ProcessMetadata_Details_Question) updates) => super.copyWith((message) => updates(message as ProcessMetadata_Details_Question));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details_Question create() => ProcessMetadata_Details_Question._();
  ProcessMetadata_Details_Question createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadata_Details_Question> createRepeated() => $pb.PbList<ProcessMetadata_Details_Question>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details_Question getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadata_Details_Question>(create);
  static ProcessMetadata_Details_Question _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get question => $_getMap(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get description => $_getMap(2);

  @$pb.TagNumber(4)
  $core.List<ProcessMetadata_Details_Question_VoteOption> get voteOptions => $_getList(3);
}

class ProcessMetadata_Details extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadata.Details', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'entityId', protoName: 'entityId')
    ..aOS(2, 'encryptionPublicKey', protoName: 'encryptionPublicKey')
    ..m<$core.String, $core.String>(3, 'title', entryClassName: 'ProcessMetadata.Details.TitleEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..m<$core.String, $core.String>(4, 'description', entryClassName: 'ProcessMetadata.Details.DescriptionEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..aOS(5, 'headerImage', protoName: 'headerImage')
    ..pc<ProcessMetadata_Details_Question>(6, 'questions', $pb.PbFieldType.PM, subBuilder: ProcessMetadata_Details_Question.create)
    ..hasRequiredFields = false
  ;

  ProcessMetadata_Details._() : super();
  factory ProcessMetadata_Details() => create();
  factory ProcessMetadata_Details.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadata_Details.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadata_Details clone() => ProcessMetadata_Details()..mergeFromMessage(this);
  ProcessMetadata_Details copyWith(void Function(ProcessMetadata_Details) updates) => super.copyWith((message) => updates(message as ProcessMetadata_Details));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details create() => ProcessMetadata_Details._();
  ProcessMetadata_Details createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadata_Details> createRepeated() => $pb.PbList<ProcessMetadata_Details>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata_Details getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadata_Details>(create);
  static ProcessMetadata_Details _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get encryptionPublicKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set encryptionPublicKey($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncryptionPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncryptionPublicKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get title => $_getMap(2);

  @$pb.TagNumber(4)
  $core.Map<$core.String, $core.String> get description => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get headerImage => $_getSZ(4);
  @$pb.TagNumber(5)
  set headerImage($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHeaderImage() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeaderImage() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<ProcessMetadata_Details_Question> get questions => $_getList(5);
}

class ProcessMetadata extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ProcessMetadata', package: const $pb.PackageName('dvote'), createEmptyInstance: create)
    ..aOS(1, 'version')
    ..aOS(2, 'type')
    ..a<$core.int>(3, 'startBlock', $pb.PbFieldType.O3, protoName: 'startBlock')
    ..a<$core.int>(4, 'numberOfBlocks', $pb.PbFieldType.O3, protoName: 'numberOfBlocks')
    ..aOM<ProcessMetadata_Census>(5, 'census', subBuilder: ProcessMetadata_Census.create)
    ..aOM<ProcessMetadata_Details>(6, 'details', subBuilder: ProcessMetadata_Details.create)
    ..m<$core.String, $core.String>(100, 'meta', entryClassName: 'ProcessMetadata.MetaEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('dvote'))
    ..hasRequiredFields = false
  ;

  ProcessMetadata._() : super();
  factory ProcessMetadata() => create();
  factory ProcessMetadata.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessMetadata.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ProcessMetadata clone() => ProcessMetadata()..mergeFromMessage(this);
  ProcessMetadata copyWith(void Function(ProcessMetadata) updates) => super.copyWith((message) => updates(message as ProcessMetadata));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata create() => ProcessMetadata._();
  ProcessMetadata createEmptyInstance() => create();
  static $pb.PbList<ProcessMetadata> createRepeated() => $pb.PbList<ProcessMetadata>();
  @$core.pragma('dart2js:noInline')
  static ProcessMetadata getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessMetadata>(create);
  static ProcessMetadata _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get startBlock => $_getIZ(2);
  @$pb.TagNumber(3)
  set startBlock($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStartBlock() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartBlock() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get numberOfBlocks => $_getIZ(3);
  @$pb.TagNumber(4)
  set numberOfBlocks($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNumberOfBlocks() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumberOfBlocks() => clearField(4);

  @$pb.TagNumber(5)
  ProcessMetadata_Census get census => $_getN(4);
  @$pb.TagNumber(5)
  set census(ProcessMetadata_Census v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCensus() => $_has(4);
  @$pb.TagNumber(5)
  void clearCensus() => clearField(5);
  @$pb.TagNumber(5)
  ProcessMetadata_Census ensureCensus() => $_ensure(4);

  @$pb.TagNumber(6)
  ProcessMetadata_Details get details => $_getN(5);
  @$pb.TagNumber(6)
  set details(ProcessMetadata_Details v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDetails() => $_has(5);
  @$pb.TagNumber(6)
  void clearDetails() => clearField(6);
  @$pb.TagNumber(6)
  ProcessMetadata_Details ensureDetails() => $_ensure(5);

  @$pb.TagNumber(100)
  $core.Map<$core.String, $core.String> get meta => $_getMap(6);
}

