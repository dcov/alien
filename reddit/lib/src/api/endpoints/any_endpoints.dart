part of '../endpoints.dart';

mixin AnyEndpoints on EndpointInteractor {

  Future<Iterable<ScopeData>> getScopeDescriptions([Iterable<String> scopes]) {
    final String parameter = scopes != null
        ? '?scopes=${scopes.join(' ')}'
        : '';
    return get('${_kOAuthUrl}/api/v1/scopes${parameter}')
        .then((String json) => ScopeData.iterableFromJson(json));
  }
}
