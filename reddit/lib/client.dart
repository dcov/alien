import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:uuid/uuid.dart';

const kAuthorizationUrl = "https://www.reddit.com/api/v1/authorize.compact";
const kAccessTokenUrl = "https://www.reddit.com/api/v1/access_token";
const kOAuthUrl = "https://oauth.reddit.com";
const kModUrl = "https://mod.reddit.com";
const kRawJsonArg = '.json?raw_json=1';

IOClient _ioClient = IOClient();
set redditIOClient(IOClient ioClient) {
  if (ioClient != null) {
    _ioClient = ioClient;
  }
}

String _deviceId = _createDeviceId();
set deviceId(String newId) {
  if (newId != null) {
    _deviceId = newId;
  }
}

String _createDeviceId() {
  String id = Uuid().v1().toString();
  if (id.length > 30) {
    id = id.substring(0, 29);
  }
  return id;
}

const _kAuthHeaderKey = "Authorization";
const _kFormHeaderKey = "Content-Type";
const _kFormHeaderValue = "application/x-www-form-urlencoded";

Map<String, String> _addFormHeader(Map<String, String> headers) {
  headers[_kFormHeaderKey] = _kFormHeaderValue;
  return headers;
}

class RedditClient {

  RedditClient(this.id, this.redirect)
    : this._basicHeader = _addFormHeader({ _kAuthHeaderKey : 'basic ${base64.encode(utf8.encode('$id:'))}' });

  final String id;
  final String redirect;

  final Map<String, String> _basicHeader;

  Map<String, String> _bearerHeader(String token) =>
    _addFormHeader({ _kAuthHeaderKey : 'bearer $token' });

  String _extractBody(Response response) => response.body;

  Future<String> postCode({ @required String code }) =>
    _ioClient.post(
      kAccessTokenUrl,
      headers: _basicHeader,
      body: 'grant_type=authorization_code&code=$code&redirect_uri=$redirect'
    ).then(_extractBody);

  Future<String> postRefreshToken({ @required String token }) =>
    _ioClient.post(
      kAccessTokenUrl,
      headers: _basicHeader,
      body: 'grant_type=refresh_token&refresh_token=$token'
    ).then(_extractBody);

  Future<String> postDeviceToken() =>
    _ioClient.post(
      kAccessTokenUrl,
      headers: _basicHeader,
      body: 'grant_type=https://oauth.reddit.com/grants/installed_client&device_id=$_deviceId'
    ).then(_extractBody);

  Future<String> get({ @required String token, @required String url}) =>
    _ioClient.get(
      url,
      headers: _bearerHeader(token)
    ).then(_extractBody);

  Future<String> post({ @required String token, @required String url, String body }) =>
    _ioClient.post(
      url,
      body: body,
      headers: _bearerHeader(token)
    ).then(_extractBody);

  Future<String> patch({ @required String token, @required String url, String body }) =>
    _ioClient.patch(
      url,
      body: body,
      headers: _bearerHeader(token)
    ).then(_extractBody);

  Future<String> delete({ @required String token, @required String url}) =>
    _ioClient.delete(
      url,
      headers: _bearerHeader(token)
    ).then(_extractBody);
}