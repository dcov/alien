import 'dart:async';

import 'package:meta/meta.dart';
import 'package:reddit/helpers.dart';
import 'package:reddit/values.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'permission_editor.dart';

class LoginModelSideEffects with RedditMixin {

  const LoginModelSideEffects();

  PermissionEditorModel createPermissionEditorModel(
    Iterable<ScopeInfo> infos,
    Iterable<Scope> enabled,
    PermissionEditorCallback onPermissionsUpdated
  ) {
    return PermissionEditorModel(
      infos,
      enabled,
      onPermissionsUpdated,
    );
  }

  AuthSession createSession(Iterable<Scope> scopes) {
    return AuthSession(getClient(), scopes);
  }

  Future<Iterable<ScopeInfo>> getScopeDescriptions(Iterable<Scope> scopes) {
    return getInteractor().getScopeDescriptions(scopes: scopes);
  }
}

typedef LoginCallback = void Function(String code);

class LoginModel extends Model {

  LoginModel(
    this._onLogin, [
    this._sideEffects = const LoginModelSideEffects()
  ]) {
    _setup();
  }

  String get authUrl => _session?.url;

  bool get isSettingUp => _isSettingUp;
  bool _isSettingUp;

  final LoginCallback _onLogin;
  Iterable<ScopeInfo> _infos;
  Iterable<Scope> _enabled;

  @visibleForTesting
  AuthSession get session => _session;
  AuthSession _session;

  final LoginModelSideEffects _sideEffects;

  PermissionEditorModel getEditor() {
    return _sideEffects.createPermissionEditorModel(
      _infos,
      _enabled,
      _updateSession
    );
  }

  void _setup() {
    _isSettingUp = true;
    final Iterable<Scope> scopes = Scope.authValues;
    _sideEffects.getScopeDescriptions(scopes).then(
      (infos) {
        this._infos = infos;
        _isSettingUp = false;
        _updateSession(scopes);
      },
      onError: (error) {
      }
    );
  }

  void _updateSession(Iterable<Scope> enabled) {
    _enabled = enabled.toSet();
    _session = _sideEffects.createSession(enabled);
    notifyListeners();
  }

  void checkUrl(String url) {
    final uri = Uri.parse(url);

    final code = uri.queryParameters['code'];
    if (code != null) {
      if (uri.queryParameters['state'] == _session.state) {
        _onLogin(code);
      } else {
      }
      return;
    }

    final error = uri.queryParameters['error'];
    if (error != null) {
    }
  }
}

class LoginMenu extends View<LoginModel> {

  LoginMenu({
    Key key,
    @required LoginModel model,
  }) : super(key: key, model: model);

  static void show(BuildContext context, LoginModel model) {
    Navigator.push(
      context,
      FadeRoute(
        builder: (_) => LoginMenu(model: model)
      )
    );
  }

  @override
  _LoginMenuState createState() => _LoginMenuState();
}

class _LoginMenuState extends ViewState<LoginModel, LoginMenu> {

  @override
  bool get rebuildOnChanges => true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 48.0,
          child: NavigationToolbar(
            leading: BackButton(),
            middle: Text('Login to Reddit'),
            trailing: model.isSettingUp
              ? const EmptyBox()
              : IconButton(
                  onPressed: () => PermissionEditorMenu.show(context, model.getEditor()),
                  icon: Icon(Icons.edit),
                ),
          )
        ),
        Expanded(
          child:  model.isSettingUp
            ? Center(child: CircularProgressIndicator())
            : WebView(
                initialUrl: model.authUrl,
                onPageFinished: model.checkUrl,
              )
        )
      ],
    );
  }
}