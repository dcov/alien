import 'package:muex/muex.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/auth.dart';
import '../models/login.dart';
import '../models/user.dart';

import 'accounts.dart';
import 'init.dart';

class StartLogin implements Update {

  StartLogin({
    @required this.login
  }) : assert(login != null);

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
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  Future<Then> effect(EffectContext context) async {
    return context.redditApp.asDevice()
      .getScopeDescriptions()
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
    @required this.login,
    @required this.result
  }) : assert(login != null),
       assert(result != null);

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
    @required this.login,
  }) : assert(login != null);

  final Login login;

  @override
  Then update(AuthOwner owner) {
    login.status = LoginStatus.failed;

    return Then.done();
  }
}

class TryAuthenticating implements Update {

  TryAuthenticating({
    @required this.login,
    @required this.url
  }) : assert(login != null),
       assert(url != null);

  final Login login;

  final String url;

  @override
  Then update(_) {
    if (login.status == LoginStatus.authenticating)
      return Then.done();

    final queryParameters = Uri.parse(url).queryParameters;
    if (queryParameters['error'] != null) {
      return Then(_AuthenticationFailed(
        login: login));
    }

    if (queryParameters['code'] != null) {
      if (queryParameters['state'] != login.session.state) {
        return Then(_AuthenticationFailed(
          login: login));
      }

      login.status = LoginStatus.authenticating;
      return Then(_PostCode(
        login: login,
        code: queryParameters['code']));
    }
  }
}

class _AuthenticationFailed implements Update {

  _AuthenticationFailed({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  Then update(_) {
    login.status = LoginStatus.failed;
    return Then.done();
  }
}

class _PostCode implements Effect {

  _PostCode({
    @required this.login,
    @required this.code
  }) : assert(login != null),
       assert(code != null);

  final Login login;

  final String code;

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      final reddit = context.redditApp;
      final tokenData = await reddit.postCode(code);
      final accountData = await reddit
          .asUser(tokenData.refreshToken)
          .getUserAccount();

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
  Then update(AccountsOwner owner) {
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
      final newUser = AppUser(
        name: accountData.username,
        token: tokenData.refreshToken);
      return Then.all({
        // Add the new user to the accounts data
        AddUser(user: newUser),
        // Switch to the new user
        SwitchUser(to: newUser)
      });
    } 

    if (existingUser != accounts.currentUser) {
      /// The [accountData] corresponded to an existing user,
      /// but it isn't the currently signed in user so we'll switch to it.
      return Then(SwitchUser(to: existingUser));
    }

    return Then.done();
  }
}

class _PostCodeFailed implements Update {

  _PostCodeFailed({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  Then update(_) {
    login.status = LoginStatus.failed;
    return Then.done();
  }
}

