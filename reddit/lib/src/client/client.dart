import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../types/data/data.dart';
import 'token_store.dart';

class RedditClient {

  RedditClient(this._ioClient, this._store);

  final Client _ioClient;

  final TokenStore _store;

  static String _formatUrl(String subdomain, String endpoint) => 'https://$subdomain.reddit.com$endpoint';

  static String _extractBody(Response response) => response.body;

  Future<String> get(String endpoint, { String subdomain = 'oauth' }) async {
    return _ioClient.get(
      _formatUrl(subdomain, endpoint),
      headers: await _store.tokenHeader,
    ).then(_extractBody);
  }

  Future<String> post(String endpoint, { String subdomain = 'oauth', String body }) async {
    return _ioClient.post(
      _formatUrl(subdomain, endpoint),
      body: body,
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }

  Future<String> patch(String endpoint, { String subdomain = 'oauth', String body }) async {
    return _ioClient.patch(
      _formatUrl(subdomain, endpoint),
      body: body,
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }

  Future<String> delete(String endpoint, { String subdomain = 'oauth' }) async {
    return _ioClient.delete(
      _formatUrl(subdomain, endpoint),
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }
}

Map<String, String> _createBasicHeader(String value) {
  return <String, String>{
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'basic ${base64.encode(utf8.encode(value))}'
  };
}

/// A utility class that provides functionality to interact with the Reddit api as an installed application.
///
/// See also:
///   *  [createScriptClient] to access the Reddit api as a script application.
///
/// Note: For the full differences between an installed application, and script application you can refer to the Reddit
/// api documentation. In general though, an installed application is an application that is used by unknown users, and
/// is installed on their devices, i.e. a mobile application. A script application on the other hand, is an application
/// that is created for personal/developer use-cases, i.e. a bot.
class RedditApp {

  /// Creates a reddit app instance that can be used to instantiate [RedditClient]s to access the reddit api.
  ///
  /// [clientId]: (Required) The app identifier string.
  /// [appUri]: (Optional) The uri that a user is redirected to when authenticating the app. This is only needed if
  /// the app will be authenticating using the code flow i.e. if you utilize [postCode].
  /// [ioClient]: (Optional) The http client used to make requests.
  factory RedditApp({
    @required String clientId,
    String redirectUri,
    Client ioClient
  }) {

    /// Generate a random device id.
    final deviceId = Uuid().v1().toString().substring(0, 30);

    /// Create the basic header that will be used by [RedditClient] instances to make api calls.
    final basicHeader = _createBasicHeader('$clientId:');

    ioClient ??= Client();

    final RedditApp app = RedditApp._(
      redirectUri,
      deviceId,
      basicHeader,
      ioClient);

    /// Since there can only be one device based [RedditClient] instance per reddit app, we can instantiate it
    /// right away.
    app._clients[deviceId] = RedditClient(
      ioClient,
      TokenStore.asDevice(
        ioClient,
        basicHeader,
        deviceId));

    return app;
  }

  RedditApp._(
    this._redirectUri,
    this._deviceId,
    this._basicHeader,
    this._ioClient);

  final String _redirectUri;

  final String _deviceId;

  final Map<String, String> _basicHeader;

  final Map<String, RedditClient> _clients = Map<String, RedditClient>();

  final Client _ioClient;

  /// The final step in the authorization code flow, this returns [RefreshTokenData] that is first used to create a
  /// [RedditClient] instance that can later be retrieved using the [RefreshTokenData.refreshToken] value.
  ///
  /// See also:
  ///  * [AuthSession] which can be used to initiate the authorization code flow.
  Future<RefreshTokenData> postCode(String code) {
    if (_redirectUri== null) {
      throw StateError("Cannot acquire an access token without the app's uri. Initialize the Reddit instance with an appUri value.");
    }
    
    return _ioClient
      .post(
        'https://www.reddit.com/api/v1/access_token',
        headers: _basicHeader,
        body: 'grant_type=authorization_code&code=$code&redirect_uri=$_redirectUri')
      .then((Response response) {
        final RefreshTokenData data = RefreshTokenData.fromJson(response.body);
        RedditClient client = _clients[data.refreshToken];

        if (client != null) {
          client._store.replaceData(data);
        } else {
          _clients[data.refreshToken] = RedditClient(
            _ioClient,
            TokenStore.asUser(
              _ioClient,
              _basicHeader,
              data.refreshToken));
        }

        return data;
      });
  }

  /// Access the Reddit api using the unique device id, i.e. as an anonymous user.
  RedditClient asDevice() => _clients[_deviceId];

  /// Access the Reddit api on behalf of the user the [refreshToken] corresponds to.
  RedditClient asUser(String refreshToken) {
    return _clients.putIfAbsent(
      refreshToken,
      () => RedditClient(
        _ioClient,
        TokenStore.asUser(
          _ioClient,
          _basicHeader,
          refreshToken))
    );
  }
}

/// Creates a [RedditClient] that authenticates itself, and accesses the Reddit api, as a script application.
RedditClient createScriptClient({
    @required String clientId,
    @required String clientSecret,
    String username,
    String password,
    Client ioClient
    }) {
  assert(clientId != null);
  assert(clientSecret != null);

  ioClient ??= Client();

  // Create the basic auth header which utilizes the client id and secret as the credentials.
  final basicHeader = _createBasicHeader('$clientId:$clientSecret');

  // Create the store in script mode.
  final store = TokenStore.asScript(
    ioClient,
    basicHeader,
    username,
    password);

  return RedditClient(
    ioClient,
    store);
}

