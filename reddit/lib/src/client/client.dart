import 'dart:convert';

import 'package:http/http.dart';
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

class Reddit {

  /// Creates a reddit app instance that can be used to instantiate [RedditClient]s to access the reddit api.
  ///
  /// [appId]: The id string of the app.
  /// [appUri]: (Optional) The uri that a user is redirected to when authenticating the app. This is only needed if
  /// the app will be acquiring the initial access token for a user, i.e. if you call [postCode].
  factory Reddit(String appId, [String appUri, Client ioClient]) {

    /// Generate a random device id.
    final String deviceId = Uuid().v1().toString().substring(0, 30);

    /// Create the basic header that will be used by [RedditClient] instances to make api calls.
    final Map<String, String> basicHeader = {
      'Content-Type' : 'application/x-www-form-urlencoded',
      'Authorization' : 'basic ${base64.encode(utf8.encode('${appId}:'))}'
    };

    ioClient ??= Client();

    final Reddit reddit = Reddit._(
      appUri,
      deviceId,
      basicHeader,
      ioClient);

    /// Since there can only be one device based [RedditClient] instance per reddit app, we can instantiate it
    /// right away.
    reddit._clients[deviceId] = RedditClient(
      ioClient,
      TokenStore.asDevice(
        ioClient,
        basicHeader,
        deviceId));

    return reddit;
  }

  Reddit._(
    this._appUri,
    this._deviceId,
    this._basicHeader,
    this._ioClient);

  final String _appUri;

  final String _deviceId;

  final Map<String, String> _basicHeader;

  final Map<String, RedditClient> _clients = Map<String, RedditClient>();

  final Client _ioClient;

  Future<RefreshTokenData> postCode(String code) {
    if (_appUri == null) {
      throw StateError("Cannot acquire an access token without the app's uri. Initialize the Reddit instance with an appUri value.");
    }
    
    return _ioClient
      .post(
        'https://www.reddit.com/api/v1/access_token',
        headers: _basicHeader,
        body: 'grant_type=authorization_code&code=$code&redirect_uri=$_appUri')
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

  RedditClient asDevice() => _clients[_deviceId];

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

