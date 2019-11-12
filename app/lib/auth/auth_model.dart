part of 'auth.dart';

@abs
abstract class RootAuth implements Model {
  Auth get auth;
}

abstract class Auth implements Model {

  factory Auth({
    @required String clientId,
    @required String redirectUri
  }) => _$Auth(
    clientId: clientId,
    redirectUri: redirectUri,
    users: const <User>{}
  );

  String get clientId;

  String get redirectUri;

  User currentUser;

  Set<User> get users;
}
