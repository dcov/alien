import 'dart:convert' show json;

import 'package:mal/mal.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/user.dart';

import 'utils.dart';

// Hive storage keys
const _kAccountsBoxKey = 'accounts';
const _kUsersDataKey = 'users';
const _kCurrentUserDataKey = 'current_user';

// Packed JSON data keys
const _kUserNameKey = 'name';
const _kUserTokenKey = 'token';

@visibleForTesting
String packUsersList(List<AppUser> users) {
  final data = users.map((AppUser user) =>
      { _kUserNameKey : user.name, _kUserTokenKey : user.token }).toList();
  return json.encode(data);
}

@visibleForTesting
List<AppUser> unpackUsersList(String jsonData) {
  final data = json.decode(jsonData) as List<dynamic>;
  return data.map((userData) =>
      AppUser(name: userData[_kUserNameKey], token: userData[_kUserTokenKey])).toList();
}

/// Starts the initialization process of retrieving and unpacking any stored [Accounts] data.
///
/// [onInitialized] is called once the data has been retrieved and unpacked successfully, otherwise [onFailed] is called
/// if along the way there is an error.
class InitAccounts implements Update {

  InitAccounts({
    @required this.onInitialized,
    @required this.onFailed,
  }) : assert(onInitialized != null),
       assert(onFailed != null);

  /// Called once the [Accounts] data has been initialized.
  final ThenCallback onInitialized;

  /// Called if there is an error in initializing the [Accounts] data.
  final ThenCallback onFailed;

  @override
  Then update(AccountsOwner owner) {
    // Check if we're running in script mode, in which case we need to get the script user's data.
    if (owner.accounts.isInScriptMode) {
      return Then(_GetScriptUserData(
        onInitialized: onInitialized,
        onFailed: onFailed));
    }

    // Kick off a side effect to retrieve any stored users data.
    return Then(_GetPackedAccountsData(
      onInitialized: onInitialized,
      onFailed: onFailed));
  }
}

class _GetScriptUserData implements Effect {

  _GetScriptUserData({
    this.onInitialized,
    this.onFailed
  }) : assert(onInitialized != null),
       assert(onFailed != null);

  final ThenCallback onInitialized;

  final ThenCallback onFailed;

  @override
  Future<Then> effect(EffectContext context) async {
    return context.scriptClient
      .getUserAccount()
      .then((AccountData data) {
         return Then(_AddScriptUser(
            data: data,
            onInitialized: onInitialized));
       },
       onError: (_) => onFailed());
  }
}

class _AddScriptUser implements Update {

  _AddScriptUser({
   @required this.data,
   @required this.onInitialized
  }) : assert(data != null),
       assert(onInitialized != null);

  final AccountData data;

  final ThenCallback onInitialized;

  @override
  Then update(AccountsOwner owner) {
    final user = ScriptUser(data.username);
    owner.accounts..users.add(user)
                  ..currentUser = user;
    return onInitialized();
  }
}

class _GetPackedAccountsData implements Effect {

  _GetPackedAccountsData({
    @required this.onInitialized,
    @required this.onFailed
  }) : assert(onInitialized != null),
       assert(onFailed != null);

  final ThenCallback onInitialized;

  final ThenCallback onFailed;

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      final accountsBox = await context.hive.openBox<String>(_kAccountsBoxKey);
      final usersData = accountsBox.get(_kUsersDataKey);
      final currentUserData = accountsBox.get(_kCurrentUserDataKey);
      return Then(_UnpackAccountsData(
        usersData: usersData,
        currentUserData: currentUserData,
        onInitialized: onInitialized));
    } catch (_) {
      return onFailed();
    }
  }
}

class _UnpackAccountsData implements Update {

  _UnpackAccountsData({
    this.usersData,
    this.currentUserData,
    @required this.onInitialized,
  }) : assert(onInitialized != null);

  final String usersData;

  final String currentUserData;

  final ThenCallback onInitialized;

  @override
  Then update(AccountsOwner owner) {
    if (usersData != null) {
      final accounts = owner.accounts;
      accounts.users.addAll(unpackUsersList(usersData));
      
      if (currentUserData != null) {
        accounts.currentUser = accounts.users.firstWhere(
            (User user) => user.name == currentUserData,
            orElse: () => null);
      }
    }

    return onInitialized();
  }
}

class AddUser implements Update {

  AddUser({
    @required this.user,
  }) : assert(user != null);

  final User user;

  @override
  Then update(AccountsOwner owner) {
    assert(!owner.accounts.isInScriptMode,
      'Cannot add user while app is running in script mode.');

    final accounts = owner.accounts;
    assert(() {
        for (final existingUser in accounts.users) {
          if (existingUser.name == user.name) {
            return false;
          }
        }
        return true;
      }(),
      'AddUser dispatched with an existing user');

    accounts.users.add(user);

    return Then(_PutPackedAccountsData(
      usersData: packUsersList(accounts.users.cast<AppUser>()),
      currentUserData: accounts.currentUser?.name));
  }
}

class RemoveUser implements Update {

  RemoveUser({
    @required this.user
  }) : assert(user != null);

  final User user;

  @override
  Then update(AccountsOwner owner) {
    assert(!owner.accounts.isInScriptMode,
      'Cannot remove user while app is running in script mode.');

    final accounts = owner.accounts;
    assert(() {
        for (final existingUser in accounts.users) {
          if (existingUser.name == user.name) {
            return true;
          }
          return false;
        }
      }(),
      'RemoveUser dispatched with a non-existing user');

    accounts.users.removeWhere((User existingUser) {
      return existingUser.name == user.name;
    });

    return Then(_PutPackedAccountsData(
      usersData: packUsersList(accounts.users.cast<AppUser>()),
      currentUserData: accounts.currentUser?.name));
  }
}

class SetCurrentUser implements Update {
  
  SetCurrentUser({ this.to });

  final User to;

  @override
  Then update(AccountsOwner owner) {
    final accounts = owner.accounts;
    assert(to != accounts.currentUser,
      'Tried to set currentUser but was already currentUser');

    accounts.currentUser = to;

    /// If we're in script mode we don't store any changes to currentUser.
    if (accounts.isInScriptMode)
      return Then.done();

    return Then(_PutPackedAccountsData(
      usersData: packUsersList(accounts.users.cast<AppUser>()),
      currentUserData: accounts.currentUser?.name));
  }
}

class _PutPackedAccountsData implements Effect {

  _PutPackedAccountsData({
    @required this.usersData,
    this.currentUserData,
  }) : assert(usersData != null);

  final String usersData;

  final String currentUserData;

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      final box = await context.hive.openBox<String>(_kAccountsBoxKey);
      await box.putAll({
        _kUsersDataKey : usersData,
        _kCurrentUserDataKey : currentUserData
      });

    } catch (_) {
      // TODO: better handle this error case
    }

    return Then.done();
  }
}

