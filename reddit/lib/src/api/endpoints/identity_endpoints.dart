part of '../endpoints.dart';

mixin IdentityEndpoints on EndpointInteractor {

  Future<AccountData> getUserAccount() {
    return get('${_kOAuthUrl}/api/v1/me')
        .then((String json) {
          return AccountData.fromJson(json);
        });
  }
}
