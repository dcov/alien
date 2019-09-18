part of '../client.dart';

@visibleForTesting
abstract class TokenStore {

  TokenStore(this._client);

  final RedditClient _client;

  Client get _ioClient => RedditClient._ioClient;

  int _expirationUtc;
  Map<String, String> _header;
  Future<Map<String, String>> _futureHeader;

  Future<Map<String, String>> get tokenHeader {
    return _futureHeader
        ?? _isHeaderValid() ? Future.value(_header) : _updateToken();
  }

  bool _isHeaderValid() {
    return _header != null
        && _expirationUtc > _currentUtc;
  }

  int get _currentUtc => DateTime.now().millisecondsSinceEpoch;

  Future<Map<String, String>> _updateToken() {
    _futureHeader = postTokenRequest().then((Response response) {
      final AccessTokenData data = AccessTokenData.fromJson(response.body);
      _expirationUtc = _currentUtc + (data.expiresIn * 1000) - 30000;
      _header = {
        _kFormHeaderKey : _kFormHeaderValue,
        _kAuthorizationHeaderKey : 'bearer ${data.token}'
      };
      _futureHeader = null;
      return _header;
    });
    return _futureHeader;
  }

  @protected
  @visibleForTesting
  Future<Response> postTokenRequest();
}

@visibleForTesting
class DeviceStore extends TokenStore {

  DeviceStore(RedditClient client) : super(client);

  @override
  Future<Response> postTokenRequest() {
    return _ioClient.post(
      _kAccessTokenUrl,
      headers: _client._basicHeader,
      body: 'grant_type=https://oauth.reddit.com/grants/installed_client'
            '&device_id=${_client._deviceId}',
    );
  }
}

@visibleForTesting
class RefreshStore extends TokenStore {

  RefreshStore(this._token, RedditClient client) : super(client);

  final String _token;

  @override
  Future<Response> postTokenRequest() {
    return _ioClient.post(
      _kAccessTokenUrl,
      headers: _client._basicHeader,
      body: 'grant_type=refresh_token&refresh_token=${_token}'
    );
  }
}
