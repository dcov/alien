import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:reddit/src/api/endpoints.dart';
import 'package:reddit/types.dart';
import 'package:uuid/uuid.dart';

import 'endpoints.dart';

part 'client/interactor.dart';
part 'client/token_store.dart';

const String _kAccessTokenUrl = 'https://www.reddit.com/api/v1/access_token';

const String _kFormHeaderKey = 'Content-Type';

const String _kFormHeaderValue = 'application/x-www-form-urlencoded';

const String _kAuthorizationHeaderKey = 'Authorization';

class RedditClient {

  RedditClient(String id, this._redirectUri)
    : this._deviceId = Uuid().v1().toString().substring(0, 30),
      this._basicHeader = {
        _kFormHeaderKey : _kFormHeaderValue,
        _kAuthorizationHeaderKey : 'basic ${base64.encode(utf8.encode('${id}:'))}'
      } {
    _interactors[_deviceId] = RedditInteractor(this, DeviceStore(this));
  }
  
  final String _redirectUri;

  final String _deviceId;

  final Map<String, String> _basicHeader;

  final Map<String, RedditInteractor> _interactors = Map<String, RedditInteractor>();

  static Client _ioClient = Client();
  static set ioClient(Client value) {
    assert(value != null);
    _ioClient = value;
  }

  Future<RefreshTokenData> postCode(String code) {
    return _ioClient
      .post(
        _kAccessTokenUrl,
        headers: _basicHeader,
        body: 'grant_type=authorization_code&code=$code&redirect_uri=$_redirectUri')
      .then((Response response) {
        final RefreshTokenData data = RefreshTokenData.fromJson(response.body);
        RedditInteractor interactor = _interactors[data.refreshToken];

        if (interactor != null) {
          interactor._store.replaceData(data);
        } else {
          _interactors[data.refreshToken] = RedditInteractor(this, RefreshStore(data.refreshToken, this));
        }

        return data;
      });
  }

  RedditInteractor asDevice() => _interactors[_deviceId];

  RedditInteractor asUser(String token) {
    return _interactors.putIfAbsent(
      token,
      () => RedditInteractor(this, RefreshStore(token, this))
    );
  }
}

