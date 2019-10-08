part of 'app.dart';

abstract class AppState extends Model {

  factory AppState({
    @required String clientId,
    @required String redirectUri,
  }) {
    return _$AppState(
      initialized: false,
      auth: Authorization(
        clientId: clientId,
        redirectUri: redirectUri
      ),
      routing: Routing(),
      theming: Theming()
    );
  }

  bool initialized;

  final Authorization auth;

  final Routing routing;

  final Theming theming;
}
