part of 'authorization.dart';

abstract class Authorization implements Model {

  factory Authorization({
    @required String clientId,
    @required String redirectUri
  }) => _$Authorization(
    clientId: clientId,
    redirectUri: redirectUri,
    users: const <User>{}
  );

  String get clientId;

  String get redirectUri;

  User currentUser;

  Set<User> get users;
}
