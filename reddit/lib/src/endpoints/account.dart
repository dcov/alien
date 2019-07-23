import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'interactor.dart';

mixin AccountEndpointsMixin on EndpointInteractor {

  Future<void> postBlockAccount({
    @required String fullAccountId
  }) => post(
      scope: Scope.account,
      requiresBearer: true,
      url: '$kOAuthUrl/api/block_user',
      body: 'account_id=$fullAccountId'
    );
}