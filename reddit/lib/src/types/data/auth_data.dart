part of '../data.dart';

class RefreshTokenData {

  factory RefreshTokenData.fromJson(String json) {
    return RefreshTokenData(jsonDecode(json));
  }

  RefreshTokenData(this._data);

  final Map _data;

  Iterable<Scope> get scopes sync* {
    final Iterable<String> values = _data['scope'].split(' ');
    for (final String value in values) {
      yield Scope.from(value);
    }
  }

  String get token => _data['refresh_token'];
}

class AccessTokenData {

  factory AccessTokenData.fromJson(String json) {
    return AccessTokenData(jsonDecode(json));
  }

  AccessTokenData(this._data);

  final Map _data;

  int get expiresIn => _data['expires_in'];

  String get token => _data['access_token'];
}
