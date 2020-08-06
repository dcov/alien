import 'package:elmer/elmer.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';

part 'auth.msg.dart';

Future<Map<String, String>> retrieveUsers(EffectContext context) async {
  final Box box = await context.hive.openBox('auth');
  Map users = box.get('users');
  return users?.cast<String, String>() ?? Map<String, String>();
}

Future<String> retrieveSignedInUser(EffectContext context) async {
  final Box box = await context.hive.openBox('auth');
  return box.get('currentUser');
}

@action initAuth(AuthOwner owner, { @required Map<String, String> users, @required String signedInUser }) {
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

@action loginStart(AuthOwner owner) {
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

@effect getPermissions(EffectContext context) async {
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

@action getPermissionsSuccess(AuthOwner owner, { @required Iterable<ScopeData> result }) {
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

@action getPermissionsFailure(AuthOwner owner) {
  final Auth auth = root.auth;
  auth.permissionsStatus = PermissionsStatus.notLoaded;
}

@action resetAuthSession(AuthOwner owner) {
  final Auth auth = owner.auth;
  auth.session = AuthSession(
    auth.appId,
    auth.appRedirect,
    auth.permissions
      .where((Permission permission) => permission.enabled)
      .map((Permission permission) => permission.id),
  );
}

@action resetPermissions(AuthOwner owner) {
  final Auth auth = owner.auth;
  for (final Permission permission in auth.permissions) {
    permission.enabled = true;
  }
}

@action togglePermission(_, { @required Permission permission }) {
  permission.enabled = !permission.enabled;
}

@action checkUrl(AuthOwner owner) {
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

@action loginSuccess(AuthOwner owner, { @required String code }) {
  final Auth auth = owner.auth;
  auth.authenticating = true;
  return PostCode(code: code);
}

@action loginError(_) {
  // TODO: implement
}

@effect postCode(EffectContext context, { @required String code }) async {
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

@action postCodeSuccess(AuthOwner owner, { @required RefreshTokenData token, @required AccountData account }) {
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

@action postCodeFailure(AuthOwner owner) {
  owner.auth.authenticating = false;
}

@effect storeUser(EffectContext context, { @required User user }) async {
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

@action storeUserFail(_) {
  // TODO: implement
}

@effect storeSignedInUser(EffectContext context, { User user }) async {
  try {
    final Box box = await context.hive.openBox('auth');
    await box.put('currentUser', user?.name);
  } catch (_) {
    return StoreSignedInUserFailure();
  }
}

@action storeSignedInUserFailure(_) {
  // TODO: Implement
}

@action logOutUser(AuthOwner owner, { @required User user }) {
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

@effect removeStoredUser(EffectContext context, { @required User user) async {
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

@action removeStoredUserFailure(_) {
  // TODO: Implement
}

@action logInUser(AuthOwner owner, { @required User user }) {
  final Auth auth = owner.auth;
  assert(auth.users.contains(user));
  final bool changedUser = (auth.currentUser != user);
  auth.currentUser = user;
  if (changedUser) {
    /// TODO: Find a different way of implementing this instead of a ProxyEvent
    /// return UserChanged();
  }
}

