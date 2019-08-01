part of '../endpoints.dart';

mixin IdentityEndpoints on EndpointInteractor {

  Future<AccountData> getMyAccount() {
    return get('${_kOAuthUrl}/api/v1/me')
        .then((String json) => AccountData.fromJson(json));
  }
}
