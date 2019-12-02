part of '../client.dart';

@visibleForTesting
abstract class TokenStore {

  TokenStore(this._client);

  final RedditClient _client;
  int _expirationUtc;
  Map<String, String> _header;
  Future<Map<String, String>> _futureHeader;

  Future<Map<String, String>> get tokenHeader {
    return _futureHeader
        ?? _isHeaderValid() ? Future.value(_header) : _updateHeader();
  }

  /// Replaces the current state with [data]. If there is a request for a token
  /// in progress when this is called, it will be ignored and this data will be
  /// used going forward.
  void replaceData(AccessTokenData data) {
    _futureHeader = null;
    _setHeader(data);
  }

  int get _currentUtc => DateTime.now().millisecondsSinceEpoch;

  bool _isHeaderValid() {
    return _header != null
        && _expirationUtc > _currentUtc;
  }

  Future<Map<String, String>> _updateHeader() {
    _futureHeader = postTokenRequest().then((Response response) {
      if (_futureHeader != null) {
        _setHeader(AccessTokenData.fromJson(response.body));
        _futureHeader = null;
      }
      return _header;
    });
    return _futureHeader;
  }

  void _setHeader(AccessTokenData data) {
    _expirationUtc = _currentUtc + (data.expiresIn * 1000) - 30000;
    _header = {
      _kFormHeaderKey : _kFormHeaderValue,
      _kAuthorizationHeaderKey : 'bearer ${data.accessToken}'
    };
  }

  @protected
  @visibleForTesting
  Future<Response> postTokenRequest();

  @protected
  Client get ioClient => RedditClient._ioClient;
}

@visibleForTesting
class DeviceStore extends TokenStore {

  DeviceStore(RedditClient client) : super(client);

  @override
  Future<Response> postTokenRequest() {
    return ioClient.post(
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
    return ioClient.post(
      _kAccessTokenUrl,
      headers: _client._basicHeader,
      body: 'grant_type=refresh_token&refresh_token=${_token}'
    );
  }
}
