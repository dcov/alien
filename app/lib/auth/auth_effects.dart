part of 'auth.dart';

class GetPermissions extends Effect {

  const GetPermissions();

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Iterable<ScopeData> data = await context.client
              .asDevice()
              .getScopeDescriptions();
      return GetPermissionsSuccess(data: data);
    } catch (_) {
      return GetPermissionsFail();
    }
  }
}

class PostCode extends Effect {

  const PostCode({ @required this.code });

  final String code;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final RedditClient client = context.client;
      final RefreshTokenData tokenData = await client.postCode(code);

      final AccountData accountData = await client
          .asUser(tokenData.refreshToken)
          .getUserAccount();

      return PostCodeSuccess(
        token: tokenData,
        account: accountData 
      );
    } catch (_) {
      return PostCodeFail();
    }
  }
}

class StoreUser extends Effect {

  StoreUser({ @required this.user });

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

class StoreSignedInUser extends Effect {

  StoreSignedInUser({ this.user });

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final Box box = await context.hive.openBox('auth');
      await box.put('currentUser', user?.name);
    } catch (_) {
      return StoreSignedInUserFail();
    }
  }
}

class RemoveStoredUser extends Effect {

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

