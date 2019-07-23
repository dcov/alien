import 'package:built_value/built_value.dart';

part 'misc.g.dart';

abstract class ScopeInfo implements Built<ScopeInfo, ScopeInfoBuilder> {

  ScopeInfo._();
  factory ScopeInfo([udpates(ScopeInfoBuilder b)]) = _$ScopeInfo;

  @nullable String get id;
  @nullable String get name;
  @nullable String get description;
}

abstract class Multi implements Built<Multi, MultiBuilder> {

  factory Multi([updates(MultiBuilder b)]) = _$Multi;
  Multi._();
  
  @nullable double get timestamp;
  @nullable bool get canEdit;
  @nullable String get name;
  @nullable String get descriptionHtml;
  @nullable bool get isNSFW;
  @nullable String get path;
  @nullable Iterable<String> get subreddits;
}