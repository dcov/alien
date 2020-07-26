import 'package:elmer/elmer.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth_model.dart';

class GetPermissions implements Effect {

  GetPermissions();

  @override
  Future<Event> perform(EffectContext context) async {
    return context.reddit
      .asDevice()
      .getScopeDescriptions()
      .then((Iterable<ScopeData> data) {
        return GetPermissionsSuccess(data: data);
      })
      .catchError((_) {
        return GetPermissionsFailure();
      });
  }
}

class PostCode implements Effect {

  PostCode({
    @required this.code
  });

  final String code;

  @override
  Future<Event> perform(EffectContext context) async {
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

class StoreUser implements Effect {

  StoreUser({
    @required this.user
  });

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      Map users = box.get('users') ?? Map();
      assert(!users.containsKey(user.name));
      users[user.name] = user.token;
      await box.put('users', users);
    } catch (_) {
      return StoreUserFail();
    }

    // Nothing else needs to happen once this succeeds so we return null.
    return null;
  }
}

class StoreSignedInUser implements Effect {

  StoreSignedInUser({
    this.user
  });

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      await box.put('currentUser', user?.name);
    } catch (_) {
      return StoreSignedInUserFail();
    }

    return null;
  }
}

class RemoveStoredUser implements Effect {

  const RemoveStoredUser({@required this.user });

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
      return RemoveStoredUserFail();
    }
  }
}

mixin RetrieveUsers on Effect {

  @protected
  Future<Map<String, String>> retrieveUsers(EffectContext context) async {
    final Box box = await context.hive.openBox('auth');
    Map users = box.get('users');
    return users?.cast<String, String>() ?? Map<String, String>();
  }
}

mixin RetrieveSignedInUser on Effect {

  @protected
  Future<String> retrieveSignedInUser(EffectContext context) async {
    final Box box = await context.hive.openBox('auth');
    return box.get('currentUser');
  }
}

class InitAuth implements Event {

  InitAuth({
    @required this.users,
    @required this.signedInUser,
  });

  final Map<String, String> users;

  final String signedInUser;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
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

class LoginStart implements Event {

  const LoginStart();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
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

class GetPermissionsSuccess implements Event {

  const GetPermissionsSuccess({ @required this.data });

  final Iterable<ScopeData> data;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    assert(auth.permissionsStatus == PermissionsStatus.loading);
    auth.permissionsStatus = PermissionsStatus.available;
    for (final ScopeData sd in data) {
      auth.permissions.add(Permission(
        id: sd.id,
        name: sd.name,
        description: sd.description,
        enabled: true,
      ));
    }
    return <Message>{
      ResetPermissions(),
      ResetAuthSession(),
    };
  }
}

class GetPermissionsFail implements Event {

  const GetPermissionsFail();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.permissionsStatus = PermissionsStatus.notLoaded;
  }
}

class ResetAuthSession implements Event {

  const ResetAuthSession();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.session = AuthSession(
      auth.appId,
      auth.appRedirect,
      auth.permissions
        .where((Permission permission) => permission.enabled)
        .map((Permission permission) => permission.id),
    );
  }
}

class ResetPermissions implements Event {

  const ResetPermissions();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    for (final Permission permission in auth.permissions) {
      permission.enabled = true;
    }
  }
}

class TogglePermission implements Event {

  TogglePermission({ @required this.permission });

  final Permission permission;

  @override
  dynamic update(_) {
    permission.enabled = !permission.enabled;
  }
}

class CheckUrl implements Event {

  CheckUrl({ @required this.url });

  final String url;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
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

class LoginSuccess implements Event {

  LoginSuccess({ @required this.code });

  final String code;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.authenticating = true;
    return PostCode(code: code);
  }
}

class LoginError implements Event {

  const LoginError();

  /// TODO: Implement
  @override
  dynamic update(RootAuth root) { }
}

class PostCodeSuccess implements Event {

  PostCodeSuccess({
    @required this.token,
    @required this.account,
  });

  final RefreshTokenData token;

  final AccountData account;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;

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
      if (oldCurrentUser != auth.currentUser)
        UserChanged(),
      StoreSignedInUser(user: auth.currentUser),
    };
  }
}

class PostCodeFail implements Event {

  const PostCodeFail();

  /// TODO: Implement
  @override
  dynamic update(RootAuth root) {
    root.auth.authenticating = false;
  }
}

class StoreUserFail implements Event {

  const StoreUserFail();

  /// TODO: Implement
  @override
  dynamic update(_) {}
}

class StoreSignedInUserFail implements Event {

  const StoreSignedInUserFail();

  /// TODO: Implement
  @override
  dynamic update(_) { }
}

class LogOutUser implements Event {

  const LogOutUser({ @required this.user });

  final User user;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    assert(auth.users.contains(user));
    auth.users.remove(user);
    final bool wasSignedIn = (auth.currentUser == user);
    if (wasSignedIn)
      auth.currentUser = null;

    return <Message>{
      if (wasSignedIn)
        ...{
          UserChanged(),
          StoreSignedInUser(),
        },
      RemoveStoredUser(user: user)
    };
  }
}

class RemoveStoredUserFail implements Event {

  /// TODO: Implement
  @override
  dynamic update(_) { }
}

class LogInUser extends Event {

  const LogInUser({ @required this.user });

  final User user;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    assert(auth.users.contains(user));
    final bool changedUser = (auth.currentUser != user);
    auth.currentUser = user;
    if (changedUser)
      return UserChanged();
  }
}

class UserChanged implements ProxyEvent {
  const UserChanged();
}

