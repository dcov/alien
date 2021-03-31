import 'package:muex/muex.dart';
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

abstract class Login implements Model {

  factory Login({
    required LoginStatus status,
    AuthSession? session
  }) = _$Login;

  LoginStatus get status;
  set status(LoginStatus value);

  AuthSession? get session;
  set session(AuthSession? value);
}
