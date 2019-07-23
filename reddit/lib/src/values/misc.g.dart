// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: avoid_returning_this
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: sort_constructors_first
// ignore_for_file: unnecessary_const
// ignore_for_file: unnecessary_new
// ignore_for_file: test_types_in_equals

class _$ScopeInfo extends ScopeInfo {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;

  factory _$ScopeInfo([void updates(ScopeInfoBuilder b)]) =>
      (new ScopeInfoBuilder()..update(updates)).build();

  _$ScopeInfo._({this.id, this.name, this.description}) : super._();

  @override
  ScopeInfo rebuild(void updates(ScopeInfoBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  ScopeInfoBuilder toBuilder() => new ScopeInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScopeInfo &&
        id == other.id &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, id.hashCode), name.hashCode), description.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ScopeInfo')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class ScopeInfoBuilder implements Builder<ScopeInfo, ScopeInfoBuilder> {
  _$ScopeInfo _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _description;
  String get description => _$this._description;
  set description(String description) => _$this._description = description;

  ScopeInfoBuilder();

  ScopeInfoBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _description = _$v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScopeInfo other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ScopeInfo;
  }

  @override
  void update(void updates(ScopeInfoBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$ScopeInfo build() {
    final _$result =
        _$v ?? new _$ScopeInfo._(id: id, name: name, description: description);
    replace(_$result);
    return _$result;
  }
}

class _$Multi extends Multi {
  @override
  final double timestamp;
  @override
  final bool canEdit;
  @override
  final String name;
  @override
  final String descriptionHtml;
  @override
  final bool isNSFW;
  @override
  final String path;
  @override
  final Iterable<String> subreddits;

  factory _$Multi([void updates(MultiBuilder b)]) =>
      (new MultiBuilder()..update(updates)).build();

  _$Multi._(
      {this.timestamp,
      this.canEdit,
      this.name,
      this.descriptionHtml,
      this.isNSFW,
      this.path,
      this.subreddits})
      : super._();

  @override
  Multi rebuild(void updates(MultiBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  MultiBuilder toBuilder() => new MultiBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Multi &&
        timestamp == other.timestamp &&
        canEdit == other.canEdit &&
        name == other.name &&
        descriptionHtml == other.descriptionHtml &&
        isNSFW == other.isNSFW &&
        path == other.path &&
        subreddits == other.subreddits;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, timestamp.hashCode), canEdit.hashCode),
                        name.hashCode),
                    descriptionHtml.hashCode),
                isNSFW.hashCode),
            path.hashCode),
        subreddits.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Multi')
          ..add('timestamp', timestamp)
          ..add('canEdit', canEdit)
          ..add('name', name)
          ..add('descriptionHtml', descriptionHtml)
          ..add('isNSFW', isNSFW)
          ..add('path', path)
          ..add('subreddits', subreddits))
        .toString();
  }
}

class MultiBuilder implements Builder<Multi, MultiBuilder> {
  _$Multi _$v;

  double _timestamp;
  double get timestamp => _$this._timestamp;
  set timestamp(double timestamp) => _$this._timestamp = timestamp;

  bool _canEdit;
  bool get canEdit => _$this._canEdit;
  set canEdit(bool canEdit) => _$this._canEdit = canEdit;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _descriptionHtml;
  String get descriptionHtml => _$this._descriptionHtml;
  set descriptionHtml(String descriptionHtml) =>
      _$this._descriptionHtml = descriptionHtml;

  bool _isNSFW;
  bool get isNSFW => _$this._isNSFW;
  set isNSFW(bool isNSFW) => _$this._isNSFW = isNSFW;

  String _path;
  String get path => _$this._path;
  set path(String path) => _$this._path = path;

  Iterable<String> _subreddits;
  Iterable<String> get subreddits => _$this._subreddits;
  set subreddits(Iterable<String> subreddits) =>
      _$this._subreddits = subreddits;

  MultiBuilder();

  MultiBuilder get _$this {
    if (_$v != null) {
      _timestamp = _$v.timestamp;
      _canEdit = _$v.canEdit;
      _name = _$v.name;
      _descriptionHtml = _$v.descriptionHtml;
      _isNSFW = _$v.isNSFW;
      _path = _$v.path;
      _subreddits = _$v.subreddits;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Multi other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Multi;
  }

  @override
  void update(void updates(MultiBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Multi build() {
    final _$result = _$v ??
        new _$Multi._(
            timestamp: timestamp,
            canEdit: canEdit,
            name: name,
            descriptionHtml: descriptionHtml,
            isNSFW: isNSFW,
            path: path,
            subreddits: subreddits);
    replace(_$result);
    return _$result;
  }
}
