import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show AuthSession;

import 'user.dart';

export 'user.dart';

part 'auth.g.dart';

abstract class Permission implements Model {

  factory Permission({
    String id,
    String name,
    String description,
    bool enabled,
  }) = _$Permission;

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
    String appId,
    String appRedirect,
    List<User> users = const <User>[],
    List<Permission> permissions = const <Permission>[],
    bool authenticating,
    AuthSession session,
    User currentUser,
    PermissionsStatus permissionsStatus,
  }) {
    return _$Auth(
      appId: appId,
      appRedirect: appRedirect,
      users: const <User>[],
      permissions: <Permission>[],
      authenticating: authenticating,
      permissionsStatus: permissionsStatus,
    );
  }

  String get appId;

  String get appRedirect;

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

