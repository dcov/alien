import 'dart:async';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';
import 'interactor.dart';

mixin IdentityEndpointsMixin on EndpointInteractor {

  Future<Account> getMyAccount() =>
    get(
      scope: Scope.identity,
      requiresBearer: true,
      url: '$kOAuthUrl/api/v1/me'
    ).then(decodeAccount);
}