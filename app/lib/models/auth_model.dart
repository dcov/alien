import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart' show AuthSession;

import '../user/user_model.dart';

part 'auth_model.g.dart';

abstract class Permission implements Model {

  factory Permission({
    @required String id,
    @required String name,
    @required String description,
    @required bool enabled,
  }) {
    return _$Permission(
      id: id,
      name: name,
      description: description,
      enabled: enabled,
    );
  }

  String get id;

  String get name;

  String get description;

  bool enabled;
}

enum PermissionsStatus {
  notLoaded,
  loading,
  available
}

abstract class Auth implements Model {

  factory Auth({
    @required String clientId,
    @required String redirectUri,
  }) {
    return _$Auth(
      clientId: clientId,
      redirectUri: redirectUri,
      users: const <User>[],
      permissions: <Permission>[],
      authenticating: false,
      permissionsStatus: PermissionsStatus.notLoaded,
    );
  }

  String get clientId;

  String get redirectUri;

  List<User> get users;

  List<Permission> get permissions;

  bool authenticating;

  AuthSession session;

  User currentUser;

  PermissionsStatus permissionsStatus;
}

@abs
abstract class RootAuth implements Model {
  Auth get auth;
}

