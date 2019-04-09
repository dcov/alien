import 'dart:async';

import 'package:meta/meta.dart';
import 'package:reddit/endpoints.dart';
import 'package:reddit/values.dart';
import 'package:reddit/helpers.dart' as helpers;
import 'package:flutter/material.dart';

import 'base.dart';
import 'login.dart';
import 'user.dart';

class AuthModelSideEffects with RedditMixin {

  const AuthModelSideEffects();

  LoginModel createLoginModel(LoginCallback onLogin) {
    return LoginModel(onLogin);
  }

  UserModel createUserModel(Account thing) {
    return UserModel(thing);
  }

  Future<Account> getAccount(RefreshToken token) {
    return RedditInteractor(client: getClient(), refreshToken: token).getMyAccount();
  }

  Future<RefreshToken> postCode(String code) {
    return helpers.postCode(client: getClient(), code: code);
  }
}

typedef AuthCallback = void Function(RefreshToken token, bool userChanged);

class AuthModel extends Model {

  @visibleForTesting
  AuthModel.withToken(
    Completer<RefreshToken> init,
    this._onAuthUpdated,
    RefreshToken token, [
    this._sideEffects = const AuthModelSideEffects()
  ]) {
    _authenticate(token, (RefreshToken token, _) {
      init.complete(token);
    });
  }

  AuthModel(
    Completer<RefreshToken> init,
    this._onAuthUpdated, [
    this._sideEffects = const AuthModelSideEffects()
  ]) {
    init.complete();
  }

  Optional<UserModel> get currentUser => _currentUser;
  Optional<UserModel> _currentUser = Optional.absent();

  Iterable<UserModel> get users => _userTokens.keys;
  final Map<UserModel, RefreshToken> _userTokens = Map<UserModel, RefreshToken>();

  final AuthCallback _onAuthUpdated;
  final AuthModelSideEffects _sideEffects;

  LoginModel getLogin() {
    return _sideEffects.createLoginModel(_postCode);
  }

  void _postCode(String code) {
    _sideEffects.postCode(code).then(
      (RefreshToken token) => _authenticate(token, _onAuthUpdated),
      onError: (error) {
      }
    );
  }

  void _authenticate(RefreshToken token, AuthCallback onAuthenticated) {
    _sideEffects.getAccount(token).then((Account account) {
      /// Check if a [UserModel] for this [account] exists already, or create a new one.
      final UserModel user = _userTokens.keys.firstWhere(
        (UserModel model) => model.matchThing(account),
        orElse: () => _sideEffects.createUserModel(account)
      );
      _userTokens[user] = token;

      final bool userChanged = !_currentUser.isPresent || _currentUser.value != user;
      _currentUser = Optional.of(user);
      onAuthenticated(token, userChanged);
      if (userChanged)
        notifyListeners();
    });
  }

  void signIn(UserModel user) {
    assert(user != null);
    assert(_userTokens.containsKey(user));
    if (_currentUser.isPresent && _currentUser.value == user)
      return;
    _currentUser = Optional.of(user);
    _onAuthUpdated(_userTokens[user], true);
    notifyListeners();
  }

  void signOut(UserModel user) {
    assert(user != null);
    assert(_userTokens.containsKey(user));
    if (!_currentUser.isPresent || _currentUser.value != user)
      return;
    _currentUser = Optional.absent();
    _onAuthUpdated(null, true);
    notifyListeners();
  }
}

class AuthMenu extends StatelessWidget {

  AuthMenu({
    Key key,
    @required this.model
  }) : super(key: key);

  final AuthModel model;

  static void show(BuildContext context, AuthModel model) {
    Navigator.push(
      context,
      FadeRoute(
        builder: (BuildContext context) {
          return AuthMenu(model: model);
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 48.0,
          child: NavigationToolbar(
            centerMiddle: false,
            leading: BackButton(),
            middle: SubheadText('Accounts'),
          )
        ),
        ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: model.users.map<Widget>((UserModel userModel) {
            return UserTile(
              model: userModel,
            );
          }).toList()..add(
            ListTile(
              onTap: () => LoginMenu.show(context, model.getLogin()),
              leading: Icon(Icons.add),
              title: Text('Login'),
            )
          )
        )
      ],
    );
  }
}