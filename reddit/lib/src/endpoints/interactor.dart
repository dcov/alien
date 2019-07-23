import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/tokens.dart';
import 'package:reddit/values.dart';
import 'exceptions.dart';

class EndpointInteractor {

  @protected
  @visibleForTesting
  EndpointInteractor(this.client, [ this._refreshToken ])
    : this._deviceStore = TokenStore.device(client),
      this._refreshStore = _refreshToken != null
        ? TokenStore.refresh(client, _refreshToken)
        : null;

  @protected
  final RedditClient client;
  final TokenStore _deviceStore;

  final RefreshToken _refreshToken;
  final TokenStore _refreshStore;

  Future<Token> _validateRequest(Scope scope, bool requiresBearer) {
    if (_refreshToken != null) {
      if (scope == Scope.any || _refreshToken.scopes.contains(scope)) {
        return _refreshStore.token;
      } else if (requiresBearer) {
        throw ScopeException(scope);
      }
    } else if (requiresBearer) {
      throw BearerException();
    }

    return _deviceStore.token;
  }

  @protected
  @visibleForTesting
  Future<String> get({
    @required Scope scope,
    @required bool requiresBearer,
    @required String url
  }) => _validateRequest(scope, requiresBearer).then((token) {
    return client.get(
      token: token.value,
      url: url
    );
  });

  @protected
  @visibleForTesting
  Future<String> post({
    @required Scope scope,
    @required bool requiresBearer,
    @required String url,
    String body
  }) => _validateRequest(scope, requiresBearer).then((token) {
    return client.post(
      token: token.value,
      url: url,
      body: body
    );
  });

  @protected
  @visibleForTesting
  Future<String> patch({
    @required Scope scope,
    @required bool requiresBearer,
    @required String url,
    String body
  }) => _validateRequest(scope, requiresBearer).then((token) {
    return client.patch(
      token: token.value,
      url: url,
      body: body
    );
  });

  @protected
  @visibleForTesting
  Future<String> delete({
    @required Scope scope,
    @required bool requiresBearer,
    @required String url
  }) => _validateRequest(scope, requiresBearer).then((token) {
    return client.delete(
      token: token.value,
      url: url
    );
  });
}