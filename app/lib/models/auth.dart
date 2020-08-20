import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show AuthSession;

import 'user.dart';

part 'auth.g.dart';

abstract class Permission extends Model {

  factory Permission({
    String id,
    String name,
    String description,
    bool enabled
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

abstract class Auth extends Model {

  factory Auth({
    String appId,
    String appRedirect,
    List<User> users,
    List<Permission> permissions,
    bool authenticating,
    AuthSession session,
    User currentUser,
    PermissionsStatus permissionsStatus
  }) = _$Auth;

  String get appId;

  String get appRedirect;

  List<User> get users;

  List<Permission> get permissions;

  bool authenticating;

  AuthSession session;

  User currentUser;

  PermissionsStatus permissionsStatus;
}

mixin AuthOwner {
  Auth get auth;
}

