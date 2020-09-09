import 'package:elmer/elmer.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/auth.dart';
import '../models/user.dart';

import 'accounts.dart';
import 'init.dart';

extension AuthExtensions on Auth {

  Login createLogin() {
    return Login(
      status: LoginStatus.idle,
      session: null);
  }
}

class StartLoginSession extends Action {

  StartLoginSession({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(AuthOwner owner) {
    assert(login.status == LoginStatus.idle);
    login.status = LoginStatus.fetchingPermissions;
    return GetPermissions(
      login: login);
  }
}

@visibleForTesting
class GetPermissions extends Effect {

  GetPermissions({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic perform(EffectContext context) async {
    return context.reddit
      .asDevice()
      .getScopeDescriptions()
      .then((Iterable<ScopeData> result) {
        return GetPermissionsSuccess(
          login: login,
          result: result);
      })
      .catchError((_) {
        return GetPermissionsFailure(login: login);
      });
  }
}

@visibleForTesting
class GetPermissionsSuccess extends Action {

  GetPermissionsSuccess({
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

@visibleForTesting
class GetPermissionsFailure extends Action {

  GetPermissionsFailure({
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
    if (queryParameters['state'] != login.session.state ||
        queryParameters['error'] != null) {
      return AuthenticationFailed(
        login: login);
    }

    if (queryParameters['code'] != null) {
      login.status = LoginStatus.authenticating;
      return PostCode(
        login: login,
        code: queryParameters['code']);
    }
  }
}

@visibleForTesting
class AuthenticationFailed extends Action {

  AuthenticationFailed({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(_) {
    login.status = LoginStatus.failed;
  }
}

@visibleForTesting
class PostCode extends Effect {

  PostCode({
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

      return PostCodeSuccess(
        tokenData: tokenData,
        accountData: accountData 
      );
    } catch (_) {
      return PostCodeFailure(
        login: login);
    }
  }
}

@visibleForTesting
class PostCodeSuccess extends Action {
  
  PostCodeSuccess({
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

@visibleForTesting
class PostCodeFailure extends Action {

  PostCodeFailure({
    @required this.login
  }) : assert(login != null);

  final Login login;

  @override
  dynamic update(_) {
    login.status = LoginStatus.failed;
  }
}

