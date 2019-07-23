import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';
import 'interactor.dart';

mixin AnyEndpointsMixin on EndpointInteractor {

  /// Retrieve descriptions of Reddit's OAuth2 scopes. An optional [scopes]
  /// parameter is provided to limit the scopes for which descriptions are
  /// retrieved. Otherwise descriptions for all available scopes are retrieved.
  Future<Iterable<ScopeInfo>> getScopeDescriptions({ Iterable<Scope> scopes }) {
    final param = scopes != null
      ? '?scopes=${Scope.makeOAuthScope(scopes)}'
      : '';
    return get(
      scope: Scope.any,
      requiresBearer: false,
      url: '$kOAuthUrl/api/v1/scopes$param'
    ).then(decodeScopeInfoIterable);
  }
}