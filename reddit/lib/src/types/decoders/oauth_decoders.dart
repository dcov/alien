part of '../decoders.dart';

class RefreshTokenDecoder {

  RefreshTokenDecoder(this._data);

  final Map _data;

  Iterable<String> get scopes => _data['scope'].split(' ');

  String get value => _data['refresh_token'];
}

class AccessTokenDecoder {

  AccessTokenDecoder(this._data);

  final Map _data;

  int get expiresIn => _data['expires_in'];

  String get value => _data['value'];
}
