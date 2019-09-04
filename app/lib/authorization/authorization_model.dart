part of 'authorization.dart';

abstract class Authorization extends Model {

  factory Authorization({
    String clientId,
    String redirectUri
  }) = _$Authorization;

  String get clientId;

  String get redirectUri;

  User currentUser;

  Set<User> get users;
}
