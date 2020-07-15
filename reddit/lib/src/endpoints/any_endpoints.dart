part of 'endpoints.dart';

extension AnyEndpoints on RedditClient {

  Future<Iterable<ScopeData>> getScopeDescriptions([Iterable<Scope> scopes]) {
    final String parameter = scopes != null
        ? '?scopes=${scopes.join(' ')}'
        : '';

    return get('/api/v1/scopes${parameter}')
        .then((String json) => ScopeData.iterableFromJson(json));
  }
}

