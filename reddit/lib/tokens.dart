import 'dart:async';
import 'client.dart';
import 'values.dart' show Token, RefreshToken;
import 'convert.dart';

/// Gives [Token.expiresIn] values 30 seconds of 'padding' so that 
/// they're updated in time.
const int _kExpirationPaddingMilliseconds = 30000;

int _millisecondsSinceEpoch() => DateTime.now().millisecondsSinceEpoch;

typedef _TokenRequest = Future<String> Function();

class TokenStore {

  factory TokenStore.device(RedditClient client) {
    _deviceStores ??= Map<String, TokenStore>();
    TokenStore store = _deviceStores[client.id];
    if (store == null) {
      store = TokenStore._(client.postDeviceToken);
      _deviceStores[client.id] = store;
    }
    return store;
  }

  factory TokenStore.refresh(RedditClient client, RefreshToken token) {
    _refreshStores ??= Map<String, TokenStore>();
    final String key = client.id + token.value;
    TokenStore store = _refreshStores[key];
    if (store == null) {
      store = TokenStore._(() => client.postRefreshToken(token: token.value));
      _refreshStores[key] = store;
    }
    return store;
  }

  TokenStore._(this._tokenRequest);

  static Map<String, TokenStore> _deviceStores;

  static Map<String, TokenStore> _refreshStores;

  final _TokenRequest _tokenRequest;
  Token _token;
  int _expirationUtc;
  Future<Token> _tokenUpdate;

  Future<Token> get token {
    return _tokenUpdate
        ?? _isTokenValid() ? Future.value(_token) : _updateToken();
  }

  bool _isTokenValid() => _token != null && _expirationUtc > _millisecondsSinceEpoch();

  Future<Token> _updateToken() {
    _tokenUpdate = _tokenRequest().then((String data) {
      _token = decodeToken(data);
      _expirationUtc = (_millisecondsSinceEpoch() + (_token.expiresIn * 1000)) - _kExpirationPaddingMilliseconds;
      _tokenUpdate = null;
      return _token;
    });
    return _tokenUpdate;
  }
}