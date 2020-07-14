part of 'endpoints.dart';

extension IdentityEndpoints on RedditClient {

  Future<AccountData> getUserAccount() {
    return get('/api/v1/me')
        .then((String json) => AccountData.fromJson(json));
  }
}

