import 'package:http/http.dart';

import '../types/data/data.dart';

// The current date time in milliseconds.
int get _currentTimeUtc => DateTime.now().millisecondsSinceEpoch;

abstract class TokenStore {

  factory TokenStore.asDevice(
    Client ioClient,
    Map<String, String> basicHeader,
    String deviceId
  ) = _DeviceStore;

  factory TokenStore.asUser(
    Client ioClient,
    Map<String, String> basicHeader,
    String refreshToken
  ) = _UserStore;

  factory TokenStore.asScript(
    Client ioClient,
    Map<String, String> basicHeader
  ) = _ScriptStore;

  TokenStore._();

  Future<Map<String, String>> _futureTokenHeader;
  Map<String, String> _tokenHeader;
  int _expirationTimeUtc;

  void _updateState(AccessTokenData data) {
    _expirationTimeUtc = _currentTimeUtc + (data.expiresIn * 1000) - 30000;
    _tokenHeader = {
      'Content-Type' : 'application/x-www-form-urlencoded',
      'Authorization' : 'bearer ${data.accessToken}'
    };
  }

  /// Replaces the current state with [data]. If there is a request for a token
  /// in progress when this is called, it will be ignored and this data will be
  /// used going forward.
  void replaceData(AccessTokenData data) {
    _updateState(data);
    // Set the _futureTokenHeader to null in case there was a request in progress.
    _futureTokenHeader = null;
  }

  Future<Response> _postTokenRequest();

  Future<Map<String, String>> _requestToken() {
    Future<Map<String, String>> future;

    future = _postTokenRequest().then((Response response) {
      // Ensure that we're still waiting on this future before updating the state
      if (_futureTokenHeader == future) {
        replaceData(AccessTokenData.fromJson(response.body));
      }
      return _tokenHeader;
    });
    _futureTokenHeader = future;

    return future;
  }

  bool get _headerIsValid => _tokenHeader != null && _expirationTimeUtc > _currentTimeUtc;

  Future<Map<String, String>> get tokenHeader =>
      _futureTokenHeader ?? _headerIsValid ? Future.value(_tokenHeader) : _requestToken();
}

class _DeviceStore extends TokenStore {

  _DeviceStore(
    this._ioClient,
    this._basicHeader,
    this._deviceId
  ) : super._();

  final Client _ioClient;

  final Map<String, String> _basicHeader;

  final String _deviceId;

  @override
  Future<Response> _postTokenRequest() {
    return _ioClient.post(
      'https://www.reddit.com/api/v1/access_token',
      headers: _basicHeader,
      body: 'grant_type=https://oauth.reddit.com/grants/installed_client&'
            'device_id=${_deviceId}',
    );
  }
}

class _UserStore extends TokenStore {

  _UserStore(
    this._ioClient,
    this._basicHeader,
    this._refreshToken
  ) : super._();

  final Client _ioClient;

  final Map<String, String> _basicHeader;

  final String _refreshToken;

  @override
  Future<Response> _postTokenRequest() {
    return _ioClient.post(
      'https://www.reddit.com/api/v1/access_token',
      headers: _basicHeader,
      body: 'grant_type=refresh_token&'
            'refresh_token=${_refreshToken}'
    );
  }
}

class _ScriptStore extends TokenStore {

  _ScriptStore(
    this._ioClient,
    this._basicHeader)
    : super._();

  final Client _ioClient;

  final Map<String, String> _basicHeader;

  @override
  Future<Response> _postTokenRequest() {
    return _ioClient.post(
      'https://www.reddit.com/api/v1/access_token',
      headers: _basicHeader,
      body: 'grant_type=client_credentials');
  }
}

