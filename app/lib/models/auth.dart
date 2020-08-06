import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show AuthSession;

import 'user.dart';

export 'user.dart';

part 'auth.mdl.dart';

@model
mixin $Permission {

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

@model
mixin $Auth {

  String get appId;

  String get appRedirect;

  List<$User> get users;

  List<$Permission> get permissions;

  bool authenticating;

  AuthSession session;

  $User currentUser;

  PermissionsStatus permissionsStatus;
}

mixin AuthOwner {
  $Auth get auth;
}

