import 'dart:convert' show json;

import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/user.dart';

import 'utils.dart';

const _kAccountsBoxKey = 'accounts';
const _kUsersDataKey = 'users';
const _kCurrentUserDataKey = 'current_user';

/// Starts the initialization process of retrieving and unpacking any stored [Accounts] data.
///
/// [onInitialized] is called once the data has been retrieved and unpacked successfully, otherwise [onFailed] is called
/// if along the way there is an error.
class InitAccounts extends Action {

  InitAccounts({
    @required this.onInitialized,
    @required this.onFailed
  }) : assert(onInitialized != null),
       assert(onFailed != null);

  /// Called once the [Accounts] data has been initialized.
  final ActionCallback onInitialized;

  /// Called if there is an error in initializing the [Accounts] data.
  final ActionCallback onFailed;

  @override
  dynamic update(AccountsOwner owner) {
    // The only work we do right now is kick off a side effect to retrieve any stored data.
    return _GetPackedAccountsData(
      onInitialized: onInitialized,
      onFailed: onFailed);
  }
}

class _GetPackedAccountsData extends Effect {

  _GetPackedAccountsData({
    @required this.onInitialized,
    @required this.onFailed
  }) : assert(onInitialized != null),
       assert(onFailed != null);

  final ActionCallback onInitialized;

  final ActionCallback onFailed;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final accountsBox = await context.hive.openBox<String>(_kAccountsBoxKey);
      final usersData = accountsBox.get(_kUsersDataKey);
      final currentUserData = accountsBox.get(_kCurrentUserDataKey);
      return _UnpackAccountsData(
        usersData: usersData,
        currentUserData: currentUserData,
        onInitialized: onInitialized);
    } catch (_) {
      return onFailed();
    }
  }
}

class _UnpackAccountsData extends Action {

  _UnpackAccountsData({
    this.usersData,
    this.currentUserData,
    @required this.onInitialized,
  }) : assert(onInitialized != null);

  final String usersData;

  final String currentUserData;

  final ActionCallback onInitialized;

  @override
  dynamic update(AccountsOwner owner) {
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

class AddUser extends Action {

  AddUser({
    @required this.user,
  }) : assert(user != null);

  final User user;

  @override
  dynamic update(AccountsOwner owner) {
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

    return _PutPackedAccountsData(
      usersData: packUsersList(accounts.users),
      currentUserData: accounts.currentUser?.name);
  }
}

class SetCurrentUser extends Action {
  
  SetCurrentUser({ this.to });

  final User to;

  @override
  dynamic update(AccountsOwner owner) {
    final accounts = owner.accounts;
    accounts.currentUser = to;

    return _PutPackedAccountsData(
      usersData: packUsersList(accounts.users),
      currentUserData: accounts.currentUser?.name);
  }
}

class _PutPackedAccountsData extends Effect {

  _PutPackedAccountsData({
    @required this.usersData,
    this.currentUserData,
  }) : assert(usersData != null);

  final String usersData;

  final String currentUserData;

  @override
  dynamic perform(EffectContext context) async {
    try {
      final box = await context.hive.openBox<String>(_kAccountsBoxKey);
      await box.putAll({
        _kUsersDataKey : usersData,
        _kCurrentUserDataKey : currentUserData
      });

    } catch (_) {
      // TODO: better handle this error case
    }
  }
}

/// PACKING LOGIC
const _kUserNameKey = 'name';
const _kUserTokenKey = 'token';

@visibleForTesting
String packUsersList(List<User> users) {
  final data = users.map((User user) =>
      { _kUserNameKey : user.name, _kUserTokenKey : user.token }).toList();
  return json.encode(data);
}

@visibleForTesting
List<User> unpackUsersList(String jsonData) {
  final data = json.decode(jsonData) as List<dynamic>;
  return data.map((userData) =>
      User(name: userData[_kUserNameKey], token: userData[_kUserTokenKey])).toList();
}

