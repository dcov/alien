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
    List<Permission> permissions,
    PermissionsStatus permissionsStatus
  }) = _$Auth;

  String get appId;

  String get appRedirect;

  List<Permission> get permissions;

  PermissionsStatus permissionsStatus;
}

abstract class AuthOwner {
  Auth get auth;
}

abstract class Login extends Model {

  factory Login({
    bool authenticating,
    AuthSession session
  }) = _$Login;

  bool authenticating;

  AuthSession session;
}

