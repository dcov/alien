import 'package:elmer/elmer.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/user.dart';

Future<Map<String, String>> retrieveUsers(EffectContext context) async {
  final Box box = await context.hive.openBox('auth');
  Map users = box.get('users');
  return users?.cast<String, String>() ?? Map<String, String>();
}

Future<String> retrieveSignedInUser(EffectContext context) async {
  final Box box = await context.hive.openBox('auth');
  return box.get('currentUser');
}

class InitAuth extends Action {

  InitAuth({
    @required this.users,
    @required this.signedInUser
  });

  final Map<String, String> users;

  final String signedInUser;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    for (final MapEntry<String, String> entry in users.entries) {
      final User user = User(
        name: entry.key,
        token: entry.value,
      );
      auth.users.add(user);
      if (user.name == signedInUser)
        auth.currentUser = user;
    }
  }
}

class LoginStart extends Action {

  LoginStart();
  
  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    assert(!auth.authenticating);

    if (auth.permissionsStatus == PermissionsStatus.notLoaded) {
      auth.permissionsStatus = PermissionsStatus.loading;
      return GetPermissions();
    }

    return <Message>{
      ResetPermissions(),
      ResetAuthSession(),
    };
  }
}

class GetPermissions extends Effect {

  GetPermissions();

  @override
  dynamic perform(EffectContext context) async {
    return context.reddit
      .asDevice()
      .getScopeDescriptions()
      .then((Iterable<ScopeData> result) {
        return GetPermissionsSuccess(result: result);
      })
      .catchError((_) {
        return GetPermissionsFailure();
      });
  }
}

class GetPermissionsSuccess extends Action {

  GetPermissionsSuccess({
    @required this.result
  });

  final Iterable<ScopeData> result;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    assert(auth.permissionsStatus == PermissionsStatus.loading);
    auth.permissionsStatus = PermissionsStatus.available;
    for (final ScopeData data in result) {
      auth.permissions.add(Permission(
        id: data.id,
        name: data.name,
        description: data.description,
        enabled: true,
      ));
    }
    return <Message>{
      ResetPermissions(),
      ResetAuthSession(),
    };
  }
}

class GetPermissionsFailure extends Action {

  GetPermissionsFailure();

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    auth.permissionsStatus = PermissionsStatus.notLoaded;
  }
}

class ResetAuthSession extends Action {

  ResetAuthSession();

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    auth.session = AuthSession(
      auth.appId,
      auth.appRedirect,
      auth.permissions
        .where((Permission permission) => permission.enabled)
        .map((Permission permission) => permission.id),
    );
  }
}

class ResetPermissions extends Action {

  ResetPermissions();

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    for (final Permission permission in auth.permissions) {
      permission.enabled = true;
    }
  }
}

class TogglePermission extends Action {

  TogglePermission({
    @required this.permission
  });

  final Permission permission;

  @override
  dynamic update(_) {
    permission.enabled = !permission.enabled;
  }
}

class CheckUrl extends Action {

  CheckUrl({
    @required this.url
  });

  final String url;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    if (auth.authenticating)
      return;

    final Uri uri = Uri.parse(url);
    final String code = uri.queryParameters['code'];
    if (code != null) {
      if (uri.queryParameters['state'] == auth.session.state) {
        return LoginSuccess(code: code);
      }
      return LoginError();
    }

    final String error = uri.queryParameters['error'];
    if (error != null) {
      return LoginError();
    }
  }
}

class LoginSuccess extends Action {

  LoginSuccess({
    @required this.code
  });

  final String code;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    auth.authenticating = true;
    return PostCode(code: code);
  }
}

class LoginError extends Action {

  LoginError();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class PostCode extends Effect {

  PostCode({
    @required this.code
  });

  final String code;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Reddit reddit = context.reddit;
      final RefreshTokenData tokenData = await reddit.postCode(code);

      final AccountData accountData = await reddit
          .asUser(tokenData.refreshToken)
          .getUserAccount();

      return PostCodeSuccess(
        token: tokenData,
        account: accountData 
      );
    } catch (_) {
      return PostCodeFailure();
    }
  }
}

class PostCodeSuccess extends Action {
  
  PostCodeSuccess({
    @required this.token,
    @required this.account
  });

  final RefreshTokenData token;

  final AccountData account;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;

    final User oldCurrentUser = auth.currentUser;
    bool isNewUser = false;
    auth..authenticating = false
        ..currentUser = auth.users.singleWhere(
            (User user) => (user.name == account.username),
            orElse: () {
              final User user = User(
                token: token.refreshToken,
                name: account.username,
              );
              auth.users.add(user);
              isNewUser = true;
              return user;
            }
          );

    return <Message>{
      if (isNewUser)
        StoreUser(user: auth.currentUser),
      // TODO: Find a different way of implementing this instead of a ProxyEvent
      // if (oldCurrentUser != auth.currentUser)
        // UserChanged(),
      StoreSignedInUser(user: auth.currentUser),
    };
  }
}

class PostCodeFailure extends Action {

  PostCodeFailure();

  @override
  dynamic update(AuthOwner owner) {
    owner.auth.authenticating = false;
  }
}

class StoreUser extends Effect {

  StoreUser({
    @required this.user
  });

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      Map users = box.get('users') ?? Map();
      assert(!users.containsKey(user.name));
      users[user.name] = user.token;
      await box.put('users', users);
    } catch (_) {
      return StoreUserFail();
    }
  }
}

class StoreUserFail extends Action {

  StoreUserFail();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class StoreSignedInUser extends Effect {

  StoreSignedInUser({
    this.user
  });

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      await box.put('currentUser', user?.name);
    } catch (_) {
      return StoreSignedInUserFailure();
    }
  }
}

class StoreSignedInUserFailure extends Action {

  StoreSignedInUserFailure();

  @override
  dynamic update(_) {
    // TODO: Implement
  }
}

class LogOutUser extends Action {

  LogOutUser({
    @required this.user
  });

  final User user;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    assert(auth.users.contains(user));
    auth.users.remove(user);
    final bool wasSignedIn = (auth.currentUser == user);
    if (wasSignedIn)
      auth.currentUser = null;

    return <Message>{
      if (wasSignedIn)
        ...{
          /// TODO: Find a different way of implement this instead of a ProxyEvent
          /// UserChanged(),
          StoreSignedInUser(),
        },
      RemoveStoredUser(user: user)
    };
  }
}

class RemoveStoredUser extends Effect {

  RemoveStoredUser({
    @required this.user
  });

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      final Map users = box.get('users');
      assert(users != null && users.containsKey(user.name));
      users.remove(user.name);
      await box.put('users', users);
    } catch (_) {
      return RemoveStoredUserFailure();
    }
  }
}

class RemoveStoredUserFailure extends Action {

  RemoveStoredUserFailure();

  @override
  dynamic update(_) {
    // TODO: Implement
  }
}

class LogInUser extends Action {

  LogInUser({
    @required this.user
  });

  final User user;

  @override
  dynamic update(AuthOwner owner) {
    final Auth auth = owner.auth;
    assert(auth.users.contains(user));
    final bool changedUser = (auth.currentUser != user);
    auth.currentUser = user;
    if (changedUser) {
      /// TODO: Find a different way of implementing this instead of a ProxyEvent
      /// return UserChanged();
    }
  }
}

