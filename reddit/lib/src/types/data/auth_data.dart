part of '../data.dart';

class AccessTokenData {

  factory AccessTokenData.fromJson(String json) {
    return AccessTokenData._(jsonDecode(json));
  }

  AccessTokenData._(this._data);

  final Map _data;

  int get expiresIn => _data['expires_in'];

  String get accessToken => _data['access_token'];
}

class RefreshTokenData extends AccessTokenData {

  factory RefreshTokenData.fromJson(String json) {
    return RefreshTokenData._(jsonDecode(json));
  }

  RefreshTokenData._(Map data) : super._(data);

  Iterable<Scope> get scopes sync* {
    final Iterable<String> values = _data['scope'].split(' ');
    for (final String value in values) {
      yield Scope.from(value);
    }
  }

  String get refreshToken => _data['refresh_token'];
}

