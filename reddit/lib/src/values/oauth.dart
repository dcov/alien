import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'oauth.g.dart';

/// Values associated with Reddit's OAuth2 service.

/// Each Scope is associated with a number of endpoints. This means that whenever a request is made
/// to an endpoint, the token that is used to make the request must have access to that endpoint's Scope.
class Scope extends EnumClass {
  static const Scope any = _$scopeAny;
  static const Scope account = _$scopeAccount;
  static const Scope creddits = _$scopeCreddits;
  static const Scope edit = _$scopeEdit;
  static const Scope flair = _$scopeFlair;
  static const Scope history = _$scopeHistory;
  static const Scope identity = _$scopeIdentity;
  static const Scope liveManage = _$scopeLiveManage;
  static const Scope modConfig = _$scopeModConfig;
  static const Scope modContributors = _$scopeModContributors;
  static const Scope modFlair = _$scopeModFlair;
  static const Scope modLog = _$scopeModLog;
  static const Scope modMail = _$scopeModMail;
  static const Scope modOthers = _$scopeModOthers;
  static const Scope modPosts = _$scopeModPosts;
  static const Scope modSelf = _$scopeModSelf;
  static const Scope modWiki = _$scopeModWiki;
  static const Scope mySubreddits = _$scopeMySubreddits;
  static const Scope privateMessages = _$scopePrivateMessages;
  static const Scope read = _$scopeRead;
  static const Scope report = _$scopeReport;
  static const Scope save = _$scopeSave;
  static const Scope submit = _$scopeSubmit;
  static const Scope subscribe = _$scopeSubscribe;
  static const Scope vote = _$scopeVote;
  static const Scope wikiEdit = _$scopeWikiEdit;
  static const Scope wikiRead = _$scopeWikiRead;

  static Iterable<Scope> get authValues => values.toList()..remove(any);
  static String makeOAuthScope(Iterable<Scope> scopes) => (scopes.toList()..remove(Scope.any)).join(' ');
  static Scope from(String value) {
    for (final scope in values) {
      if (scope.toString() == value) {
        return scope;
      }
    }
    return null;
  }

  static BuiltSet<Scope> get values => _$scopeValues;
  static Scope valueOf(String name) => _$scopeValueOf(name);

  const Scope._(String name) : super(name);
  
  @override 
  String toString() => this.name.toLowerCase();
}

abstract class RefreshToken implements Built<RefreshToken, RefreshTokenBuilder> {

  factory RefreshToken([updates(RefreshTokenBuilder b)]) = _$RefreshToken;
  RefreshToken._();
  
  BuiltSet<Scope> get scopes;
  String get value;

  @override
  String toString() => this.value;
}

/// A Token contains the values needed to make requests including the
/// required access token string.
abstract class Token implements Built<Token, TokenBuilder> {

  factory Token([updates(TokenBuilder b)]) = _$Token;
  Token._();

  int get expiresIn;
  String get value;

  @override
  String toString() => this.value;
}
