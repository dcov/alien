import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../types/data/data.dart';

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
  ) = _RefreshStore;

  TokenStore._();

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
      'Content-Type' : 'application/x-www-form-urlencoded',
      'Authorization' : 'bearer ${data.accessToken}'
    };
  }

  @protected
  @visibleForTesting
  Future<Response> postTokenRequest();
}

class _DeviceStore extends TokenStore {

  _DeviceStore(
    this.ioClient,
    this._basicHeader,
    this._deviceId
  ) : super._();

  final Client ioClient;

  final Map<String, String> _basicHeader;

  final String _deviceId;

  @override
  Future<Response> postTokenRequest() {
    return ioClient.post(
      'https://www.reddit.com/api/v1/access_token',
      headers: _basicHeader,
      body: 'grant_type=https://oauth.reddit.com/grants/installed_client'
            '&device_id=${_deviceId}',
    );
  }
}

class _RefreshStore extends TokenStore {

  _RefreshStore(
    this.ioClient,
    this._basicHeader,
    this._refreshToken
  ) : super._();

  final Client ioClient;

  final Map<String, String> _basicHeader;

  final String _refreshToken;

  @override
  Future<Response> postTokenRequest() {
    return ioClient.post(
      'https://www.reddit.com/api/v1/access_token',
      headers: _basicHeader,
      body: 'grant_type=refresh_token&refresh_token=${_refreshToken}'
    );
  }
}

