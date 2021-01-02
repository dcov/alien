import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../logic/login.dart';
import '../models/login.dart';
import '../widgets/pressable.dart';
import '../widgets/web_view_control.dart';
import '../widgets/widget_extensions.dart';

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
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                leading: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: PressableIcon(
                    onPress: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: Icons.close,
                    iconColor: Colors.black)))))),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: context.mediaPadding.bottom),
            child: Connector(
              builder: (BuildContext context) {
                switch (login.status) {
                  case LoginStatus.idle:
                    ServicesBinding.instance.addPostFrameCallback((_) {
                      context.then(Then(StartLogin(login: login)));
                    });
                    continue renderSettingUpIndicator;
                  renderSettingUpIndicator:
                  case LoginStatus.settingUp:
                    return _Indicator(text: 'Setting up');
                  case LoginStatus.awaitingCode:
                    return WebViewControl(
                      javascriptEnabled: true,
                      gestureNavigationEnabled: true,
                      url: login.session.url,
                      onPageFinished: (String pageUrl) {
                        context.then(
                          Then(TryAuthenticating(
                            login: login,
                            url: pageUrl)));
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
              })))
      ]);
  }
}

void showLoginScreen({ @required BuildContext context }) {
  assert(context != null);
  final login = Login(status: LoginStatus.idle);
  context.rootNavigator.push(MaterialPageRoute(builder: (_) => _LoginScreen(login: login)));
}

