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
  Action update(_) {
    assert(login.status == LoginStatus.idle);
    login.status = LoginStatus.settingUp;
    return _GetScopes(login: login);
  }
}

class _GetScopes implements Effect {

  _GetScopes({
    required this.login
  });

  final Login login;

  @override
  Future<Action> effect(CoreContext context) async {
    return context.reddit.asDevice()
      .getScopes()
      .then(
        (Iterable<ScopeData> result) {
          return _InitializeAuthSession(
            login: login,
            result: result,
          );
        },
        onError: (_) {
          return _GetScopesFailed(login: login);
        },
      );
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
  Action update(AuthOwner owner) {
    final Auth auth = owner.auth;

    // Initialize the login session
    login.session = AuthSession(
      auth.appId,
      auth.appRedirect,
      result.map((ScopeData scope) => scope.id));

    // Set that status to awaiting the user authentication code
    login.status = LoginStatus.awaitingCode;

    return None();
  }
}

class _GetScopesFailed implements Update {

  _GetScopesFailed({
    required this.login,
  });

  final Login login;

  Action update(AuthOwner owner) {
    login.status = LoginStatus.failed;
    return None();
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
  Action update(_) {
    if (login.status != LoginStatus.authenticating) {
      final queryParameters = Uri.parse(url).queryParameters;
      if (queryParameters['error'] != null) {
        return _AuthenticationFailed(login: login);
      }

      if (queryParameters['code'] != null) {
        if (queryParameters['state'] != login.session!.state) {
          return _AuthenticationFailed(login: login);
        }

        login.status = LoginStatus.authenticating;
        return _PostCode(
          login: login,
          code: queryParameters['code']!,
        );
      }
    }

    return None();
  }
}

class _AuthenticationFailed implements Update {

  _AuthenticationFailed({
    required this.login
  });

  final Login login;

  @override
  Action update(_) {
    login.status = LoginStatus.failed;
    return None();
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
  Future<Action> effect(CoreContext context) async {
    try {
      final reddit = context.reddit;
      final tokenData = await reddit.postCode(code);
      final accountData = await reddit
          .asUser(tokenData.refreshToken)
          .getMe();

      return _FinishLogin(
        login: login,
        tokenData: tokenData,
        accountData: accountData,
      );
    } catch (_) {
      return _PostCodeFailed(login: login);
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
  Action update(AccountsOwner owner) {
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
      return Unchained({
        // Add the new user to the accounts data
        AddUser(user: newUser),
        // Switch to the new user
        SetCurrentUser(to: newUser),
      });
    } 

    if (existingUser != accounts.currentUser) {
      /// The [accountData] corresponded to an existing user,
      /// but it isn't the currently signed in user so we'll switch to it.
      return SetCurrentUser(to: existingUser);
    }

    return None();
  }
}

class _PostCodeFailed implements Update {

  _PostCodeFailed({
    required this.login
  });

  final Login login;

  @override
  Action update(_) {
    login.status = LoginStatus.failed;
    return None();
  }
}
