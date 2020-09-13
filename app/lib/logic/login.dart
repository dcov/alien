import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/auth.dart';
import '../models/login.dart';
import '../models/user.dart';

import 'accounts.dart';
import 'init.dart';

class StartLogin extends Action {

  StartLogin({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(_) {
    assert(login.status == LoginStatus.idle);
    login.status = LoginStatus.settingUp;
    return _GetScopes(
      login: login);
  }
}

class _GetScopes extends Effect {

  _GetScopes({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic perform(EffectContext context) async {
    return context.reddit
      .asDevice()
      .getScopeDescriptions()
      .then((Iterable<ScopeData> result) {
        return _InitializeAuthSession(
          login: login,
          result: result);
      })
      .catchError((_) {
        return _GetScopesFailed(login: login);
      });
  }
}

class _InitializeAuthSession extends Action {

  _InitializeAuthSession({
    @required this.login,
    @required this.result
  }) : assert(login != null),
       assert(result != null);

  final Login login;

  final Iterable<ScopeData> result;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;

    // Initialize the login session
    login.session = AuthSession(
      auth.appId,
      auth.appRedirect,
      result.map((ScopeData scope) => scope.id));

    // Set that status to awaiting the user authentication code
    login.status = LoginStatus.awaitingCode;
  }
}

class _GetScopesFailed extends Action {

  _GetScopesFailed({
    @required this.login,
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(AuthOwner owner) {
    login.status = LoginStatus.failed;
  }
}

class TryAuthenticating extends Action {

  TryAuthenticating({
    @required this.login,
    @required this.url
  }) : assert(login != null),
       assert(url != null);

  final Login login;

  final String url;

  @override
  dynamic update(_) {
    if (login.status == LoginStatus.authenticating)
      return;

    final queryParameters = Uri.parse(url).queryParameters;
    if (queryParameters['error'] != null) {
      return _AuthenticationFailed(
        login: login);
    }

    if (queryParameters['code'] != null) {
      if (queryParameters['state'] != login.session.state) {
        return _AuthenticationFailed(
          login: login);
      }

      login.status = LoginStatus.authenticating;
      return _PostCode(
        login: login,
        code: queryParameters['code']);
    }
  }
}

class _AuthenticationFailed extends Action {

  _AuthenticationFailed({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(_) {
    login.status = LoginStatus.failed;
  }
}

class _PostCode extends Effect {

  _PostCode({
    @required this.login,
    @required this.code
  }) : assert(login != null),
       assert(code != null);

  final Login login;

  final String code;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final reddit = context.reddit;
      final tokenData = await reddit.postCode(code);
      final accountData = await reddit
          .asUser(tokenData.refreshToken)
          .getUserAccount();

      return _FinishLogin(
        login: login,
        tokenData: tokenData,
        accountData: accountData);
    } catch (_) {
      return _PostCodeFailed(
        login: login);
    }
  }
}

class _FinishLogin extends Action {
  
  _FinishLogin({
    @required this.login,
    @required this.tokenData,
    @required this.accountData
  }) : assert(login != null),
       assert(tokenData != null),
       assert(accountData != null);

  final Login login;

  final RefreshTokenData tokenData;

  final AccountData accountData;

  @override
  dynamic update(AccountsOwner owner) {
    login.status = LoginStatus.succeeded;

    final Accounts accounts = owner.accounts;
    User existingUser;
    for (final user in accounts.users) {
      if (user.name == accountData.username) {
        existingUser = user;
        break;
      }
    }

    if (existingUser == null) {
      /// The [accountData] does not correspond to an existing user, so we'll create a new user using it.
      final newUser = User(
        name: accountData.username,
        token: tokenData.refreshToken);
      return {
        // Add the new user to the accounts data
        AddUser(user: newUser),
        // Switch to the new user
        SwitchUser(to: newUser)
      };
    } 

    if (existingUser != accounts.currentUser) {
      /// The [accountData] corresponded to an existing user,
      /// but it isn't the currently signed in user so we'll switch to it.
      return SwitchUser(to: existingUser);
    }
  }
}

class _PostCodeFailed extends Action {

  _PostCodeFailed({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(_) {
    login.status = LoginStatus.failed;
  }
}

