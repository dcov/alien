part of 'app.dart';

abstract class App implements Model, RootAuth, RootRouting, RootTheming {

  factory App({
    @required String clientId,
    @required String redirectUri,
  }) {
    return _$App(
      initialized: false,
      auth: Auth(
        clientId: clientId,
        redirectUri: redirectUri
      ),
      routing: Routing(),
      theming: Theming()
    );
  }

  bool initialized;
}

