import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show AuthSession;

part 'auth.g.dart';

abstract class Auth extends Model {

  factory Auth({
    String appId,
    String appRedirect,
  }) = _$Auth;

  String get appId;

  String get appRedirect;
}

abstract class AuthOwner {
  Auth get auth;
}

enum LoginStatus {
  idle,
  fetchingPermissions,
  awaitingCode,
  authenticating,
  succeeded,
  failed
}

abstract class Login extends Model {

  factory Login({
    LoginStatus status,
    AuthSession session
  }) = _$Login;

  LoginStatus status;

  AuthSession session;
}

