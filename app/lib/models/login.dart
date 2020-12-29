import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show AuthSession;

part 'login.g.dart';

enum LoginStatus {
  idle,
  settingUp,
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

