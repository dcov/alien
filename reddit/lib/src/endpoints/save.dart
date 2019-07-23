import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'interactor.dart';

mixin SaveEndpointsMixin on EndpointInteractor {

  Future<void> postSave({ @required String fullThingId }) =>
    post(
      scope: Scope.save,
      requiresBearer: true,
      url: '$kOAuthUrl/api/save',
      body: 'id=$fullThingId'
    );

  Future<void> postUnsave({ @required String fullThingId }) =>
    post(
      scope: Scope.save,
      requiresBearer: true,
      url: '$kOAuthUrl/api/unsave',
      body: 'id=$fullThingId'
    );
}