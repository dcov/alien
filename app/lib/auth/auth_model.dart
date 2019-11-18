part of 'auth.dart';

@abs
abstract class RootAuth implements Model {
  Auth get auth;
}

abstract class Auth implements Model {

  factory Auth({
    @required String clientId,
    @required String redirectUri,
  }) => _$Auth(
    login: Login(
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: Scope.values
    ),
    users: const <User>{}
  );

  Login get login;

  User currentUser;

  Set<User> get users;
}

