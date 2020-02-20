import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../user/user_model.dart';

import 'auth_effects.dart';
import 'auth_model.dart';

class InitAuth extends Event {

  const InitAuth({
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

class LoginStart extends Event {

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

class GetPermissionsSuccess extends Event {

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

class GetPermissionsFail extends Event {

  const GetPermissionsFail();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.permissionsStatus = PermissionsStatus.notLoaded;
  }
}

class ResetAuthSession extends Event {

  const ResetAuthSession();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.session = AuthSession(
      auth.clientId,
      auth.redirectUri,
      auth.permissions
        .where((Permission permission) => permission.enabled)
        .map((Permission permission) => permission.id),
    );
  }
}

class ResetPermissions extends Event {

  const ResetPermissions();

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    for (final Permission permission in auth.permissions) {
      permission.enabled = true;
    }
  }
}

class TogglePermission extends Event {

  TogglePermission({ @required this.permission });

  final Permission permission;

  @override
  dynamic update(_) {
    permission.enabled = !permission.enabled;
  }
}

class CheckUrl extends Event {

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

class LoginSuccess extends Event {

  LoginSuccess({ @required this.code });

  final String code;

  @override
  dynamic update(RootAuth root) {
    final Auth auth = root.auth;
    auth.authenticating = true;
    return PostCode(code: code);
  }
}

class LoginError extends Event {

  const LoginError();

  /// TODO: Implement
  @override
  dynamic update(RootAuth root) { }
}

class PostCodeSuccess extends Event {

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

class PostCodeFail extends Event {

  const PostCodeFail();

  /// TODO: Implement
  @override
  dynamic update(RootAuth root) {
    root.auth.authenticating = false;
  }
}

class StoreUserFail extends Event {

  const StoreUserFail();

  /// TODO: Implement
  @override
  dynamic update(_) {}
}

class StoreSignedInUserFail extends Event {

  const StoreSignedInUserFail();

  /// TODO: Implement
  @override
  dynamic update(_) { }
}

class LogOutUser extends Event {

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

class RemoveStoredUserFail extends Event {

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

class UserChanged extends ProxyEvent {
  const UserChanged();
}

