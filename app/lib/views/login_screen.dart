import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/login.dart';
import '../models/auth.dart';
import '../models/login.dart';
import '../widgets/web_view_control.dart';

class _Indicator extends StatelessWidget {

  _Indicator({
    Key key,
    @required this.text,
  }) : assert(text != null),
       super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            Text(text),
          ])));
  }
}

class _LoginScreen extends StatelessWidget {

  _LoginScreen({
    Key key,
    @required this.login
  }) : super(key: key);

  final Login login;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      print('Building login screen status: ${login.status}');
      switch (login.status) {
        case LoginStatus.idle:
          ServicesBinding.instance.addPostFrameCallback((_) {
            context.dispatch(StartLogin(login: login));
          });
          continue renderSettingUpIndicator;
        renderSettingUpIndicator:
        case LoginStatus.settingUp:
          return _Indicator(text: 'Setting up');
        case LoginStatus.awaitingCode:
          return WebViewControl(
            url: login.session.url,
            onPageFinished: (String pageUrl) {
              context.dispatch(
                TryAuthenticating(
                  login: login,
                  url: pageUrl));
            });
        case LoginStatus.authenticating:
          return _Indicator(text: 'Authenticating');
        case LoginStatus.succeeded:
        case LoginStatus.failed:
          ServicesBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return Material();
      }
      return null;
    });
}

void showLoginScreen({
    @required BuildContext context,
    @required Auth auth,
  }) {
  assert(context != null);
  assert(auth != null);
  Navigator.of(context, rootNavigator: true)
    .push(MaterialPageRoute(builder: (_) => _LoginScreen(login: Login(status: LoginStatus.idle))));
}

