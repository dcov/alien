// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth.dart';

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

const Scope _$scopeAny = const Scope._('any');
const Scope _$scopeAccount = const Scope._('account');
const Scope _$scopeCreddits = const Scope._('creddits');
const Scope _$scopeEdit = const Scope._('edit');
const Scope _$scopeFlair = const Scope._('flair');
const Scope _$scopeHistory = const Scope._('history');
const Scope _$scopeIdentity = const Scope._('identity');
const Scope _$scopeLiveManage = const Scope._('liveManage');
const Scope _$scopeModConfig = const Scope._('modConfig');
const Scope _$scopeModContributors = const Scope._('modContributors');
const Scope _$scopeModFlair = const Scope._('modFlair');
const Scope _$scopeModLog = const Scope._('modLog');
const Scope _$scopeModMail = const Scope._('modMail');
const Scope _$scopeModOthers = const Scope._('modOthers');
const Scope _$scopeModPosts = const Scope._('modPosts');
const Scope _$scopeModSelf = const Scope._('modSelf');
const Scope _$scopeModWiki = const Scope._('modWiki');
const Scope _$scopeMySubreddits = const Scope._('mySubreddits');
const Scope _$scopePrivateMessages = const Scope._('privateMessages');
const Scope _$scopeRead = const Scope._('read');
const Scope _$scopeReport = const Scope._('report');
const Scope _$scopeSave = const Scope._('save');
const Scope _$scopeSubmit = const Scope._('submit');
const Scope _$scopeSubscribe = const Scope._('subscribe');
const Scope _$scopeVote = const Scope._('vote');
const Scope _$scopeWikiEdit = const Scope._('wikiEdit');
const Scope _$scopeWikiRead = const Scope._('wikiRead');

Scope _$scopeValueOf(String name) {
  switch (name) {
    case 'any':
      return _$scopeAny;
    case 'account':
      return _$scopeAccount;
    case 'creddits':
      return _$scopeCreddits;
    case 'edit':
      return _$scopeEdit;
    case 'flair':
      return _$scopeFlair;
    case 'history':
      return _$scopeHistory;
    case 'identity':
      return _$scopeIdentity;
    case 'liveManage':
      return _$scopeLiveManage;
    case 'modConfig':
      return _$scopeModConfig;
    case 'modContributors':
      return _$scopeModContributors;
    case 'modFlair':
      return _$scopeModFlair;
    case 'modLog':
      return _$scopeModLog;
    case 'modMail':
      return _$scopeModMail;
    case 'modOthers':
      return _$scopeModOthers;
    case 'modPosts':
      return _$scopeModPosts;
    case 'modSelf':
      return _$scopeModSelf;
    case 'modWiki':
      return _$scopeModWiki;
    case 'mySubreddits':
      return _$scopeMySubreddits;
    case 'privateMessages':
      return _$scopePrivateMessages;
    case 'read':
      return _$scopeRead;
    case 'report':
      return _$scopeReport;
    case 'save':
      return _$scopeSave;
    case 'submit':
      return _$scopeSubmit;
    case 'subscribe':
      return _$scopeSubscribe;
    case 'vote':
      return _$scopeVote;
    case 'wikiEdit':
      return _$scopeWikiEdit;
    case 'wikiRead':
      return _$scopeWikiRead;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<Scope> _$scopeValues = new BuiltSet<Scope>(const <Scope>[
  _$scopeAny,
  _$scopeAccount,
  _$scopeCreddits,
  _$scopeEdit,
  _$scopeFlair,
  _$scopeHistory,
  _$scopeIdentity,
  _$scopeLiveManage,
  _$scopeModConfig,
  _$scopeModContributors,
  _$scopeModFlair,
  _$scopeModLog,
  _$scopeModMail,
  _$scopeModOthers,
  _$scopeModPosts,
  _$scopeModSelf,
  _$scopeModWiki,
  _$scopeMySubreddits,
  _$scopePrivateMessages,
  _$scopeRead,
  _$scopeReport,
  _$scopeSave,
  _$scopeSubmit,
  _$scopeSubscribe,
  _$scopeVote,
  _$scopeWikiEdit,
  _$scopeWikiRead,
]);

class _$RefreshToken extends RefreshToken {
  @override
  final BuiltSet<Scope> scopes;
  @override
  final String value;

  factory _$RefreshToken([void updates(RefreshTokenBuilder b)]) =>
      (new RefreshTokenBuilder()..update(updates)).build();

  _$RefreshToken._({this.scopes, this.value}) : super._() {
    if (scopes == null) {
      throw new BuiltValueNullFieldError('RefreshToken', 'scopes');
    }
    if (value == null) {
      throw new BuiltValueNullFieldError('RefreshToken', 'value');
    }
  }

  @override
  RefreshToken rebuild(void updates(RefreshTokenBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshTokenBuilder toBuilder() => new RefreshTokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshToken &&
        scopes == other.scopes &&
        value == other.value;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, scopes.hashCode), value.hashCode));
  }
}

class RefreshTokenBuilder
    implements Builder<RefreshToken, RefreshTokenBuilder> {
  _$RefreshToken _$v;

  SetBuilder<Scope> _scopes;
  SetBuilder<Scope> get scopes => _$this._scopes ??= new SetBuilder<Scope>();
  set scopes(SetBuilder<Scope> scopes) => _$this._scopes = scopes;

  String _value;
  String get value => _$this._value;
  set value(String value) => _$this._value = value;

  RefreshTokenBuilder();

  RefreshTokenBuilder get _$this {
    if (_$v != null) {
      _scopes = _$v.scopes?.toBuilder();
      _value = _$v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshToken other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$RefreshToken;
  }

  @override
  void update(void updates(RefreshTokenBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$RefreshToken build() {
    _$RefreshToken _$result;
    try {
      _$result =
          _$v ?? new _$RefreshToken._(scopes: scopes.build(), value: value);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'scopes';
        scopes.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'RefreshToken', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$Token extends Token {
  @override
  final int expiresIn;
  @override
  final String value;

  factory _$Token([void updates(TokenBuilder b)]) =>
      (new TokenBuilder()..update(updates)).build();

  _$Token._({this.expiresIn, this.value}) : super._() {
    if (expiresIn == null) {
      throw new BuiltValueNullFieldError('Token', 'expiresIn');
    }
    if (value == null) {
      throw new BuiltValueNullFieldError('Token', 'value');
    }
  }

  @override
  Token rebuild(void updates(TokenBuilder b)) =>
      (toBuilder()..update(updates)).build();

  @override
  TokenBuilder toBuilder() => new TokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Token &&
        expiresIn == other.expiresIn &&
        value == other.value;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, expiresIn.hashCode), value.hashCode));
  }
}

class TokenBuilder implements Builder<Token, TokenBuilder> {
  _$Token _$v;

  int _expiresIn;
  int get expiresIn => _$this._expiresIn;
  set expiresIn(int expiresIn) => _$this._expiresIn = expiresIn;

  String _value;
  String get value => _$this._value;
  set value(String value) => _$this._value = value;

  TokenBuilder();

  TokenBuilder get _$this {
    if (_$v != null) {
      _expiresIn = _$v.expiresIn;
      _value = _$v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Token other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Token;
  }

  @override
  void update(void updates(TokenBuilder b)) {
    if (updates != null) updates(this);
  }

  @override
  _$Token build() {
    final _$result = _$v ?? new _$Token._(expiresIn: expiresIn, value: value);
    replace(_$result);
    return _$result;
  }
}
