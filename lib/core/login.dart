import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';
import '../reddit/utils.dart';

import 'context.dart';
import 'accounts.dart';
import 'auth.dart';
import 'user.dart';

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

class StartLogin implements Update {

  StartLogin({
    required this.login
  });

  final Login login;

  @override
  Then update(_) {
    assert(login.status == LoginStatus.idle);
    login.status = LoginStatus.settingUp;
    return Then(_GetScopes(
      login: login));
  }
}

class _GetScopes implements Effect {

  _GetScopes({
    required this.login
  });

  final Login login;

  @override
  Future<Then> effect(CoreContext context) async {
    return context.reddit.asDevice()
      .getScopes()
      .then((Iterable<ScopeData> result) {
        return Then(_InitializeAuthSession(
          login: login,
          result: result));
      })
      .catchError((_) {
        return Then(_GetScopesFailed(login: login));
      });
  }
}

class _InitializeAuthSession implements Update {

  _InitializeAuthSession({
    required this.login,
    required this.result
  });

  final Login login;

  final Iterable<ScopeData> result;

  @override
  Then update(AuthOwner owner) {
    final Auth auth = owner.auth;

    // Initialize the login session
    login.session = AuthSession(
      auth.appId,
      auth.appRedirect,
      result.map((ScopeData scope) => scope.id));

    // Set that status to awaiting the user authentication code
    login.status = LoginStatus.awaitingCode;

    return Then.done();
  }
}

class _GetScopesFailed implements Update {

  _GetScopesFailed({
    required this.login,
  });

  final Login login;

  @override
  Then update(AuthOwner owner) {
    login.status = LoginStatus.failed;

    return Then.done();
  }
}

class TryAuthenticating implements Update {

  TryAuthenticating({
    required this.login,
    required this.url
  });

  final Login login;

  final String url;

  @override
  Then update(_) {
    if (login.status != LoginStatus.authenticating) {
      final queryParameters = Uri.parse(url).queryParameters;
      if (queryParameters['error'] != null) {
        return Then(_AuthenticationFailed(
          login: login));
      }

      if (queryParameters['code'] != null) {
        if (queryParameters['state'] != login.session!.state) {
          return Then(_AuthenticationFailed(
            login: login));
        }

        login.status = LoginStatus.authenticating;
        return Then(_PostCode(
          login: login,
          code: queryParameters['code']!));
      }
    }

    return Then.done();
  }
}

class _AuthenticationFailed implements Update {

  _AuthenticationFailed({
    required this.login
  });

  final Login login;

  @override
  Then update(_) {
    login.status = LoginStatus.failed;
    return Then.done();
  }
}

class _PostCode implements Effect {

  _PostCode({
    required this.login,
    required this.code
  });

  final Login login;

  final String code;

  @override
  Future<Then> effect(CoreContext context) async {
    try {
      final reddit = context.reddit;
      final tokenData = await reddit.postCode(code);
      final accountData = await reddit
          .asUser(tokenData.refreshToken)
          .getMe();

      return Then(_FinishLogin(
        login: login,
        tokenData: tokenData,
        accountData: accountData));
    } catch (_) {
      return Then(_PostCodeFailed(
        login: login));
    }
  }
}

class _FinishLogin implements Update {
  
  _FinishLogin({
    required this.login,
    required this.tokenData,
    required this.accountData
  });

  final Login login;

  final RefreshTokenData tokenData;

  final AccountData accountData;

  @override
  Then update(AccountsOwner owner) {
    login.status = LoginStatus.succeeded;

    final Accounts accounts = owner.accounts;
    User? existingUser;
    for (final user in accounts.users) {
      if (user.name == accountData.username) {
        existingUser = user;
        break;
      }
    }

    if (existingUser == null) {
      /// The [accountData] does not correspond to an existing user, so we'll create a new user using it.
      final newUser = AppUser(
        name: accountData.username,
        token: tokenData.refreshToken);
      return Then.all({
        // Add the new user to the accounts data
        AddUser(user: newUser),
        // Switch to the new user
        SetCurrentUser(to: newUser)
      });
    } 

    if (existingUser != accounts.currentUser) {
      /// The [accountData] corresponded to an existing user,
      /// but it isn't the currently signed in user so we'll switch to it.
      return Then(SetCurrentUser(to: existingUser));
    }

    return Then.done();
  }
}

class _PostCodeFailed implements Update {

  _PostCodeFailed({
    required this.login
  });

  final Login login;

  @override
  Then update(_) {
    login.status = LoginStatus.failed;
    return Then.done();
  }
}