import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'interactor.dart';

mixin VoteEndpointsMixin on EndpointInteractor {

  Future<void> postUpvote({ @required String fullThingId }) =>
    post(
      scope: Scope.vote,
      requiresBearer: true,
      url: '$kOAuthUrl/api/vote',
      body: 'id=$fullThingId&dir=1'
    );

  Future<void> postUnvote({ @required String fullThingId }) =>
    post(
      scope: Scope.vote,
      requiresBearer: true,
      url: '$kOAuthUrl/api/vote',
      body: 'id=$fullThingId&dir=0'
    );

  Future<void> postDownvote({ @required String fullThingId }) =>
    post(
      scope: Scope.vote,
      requiresBearer: true,
      url: '$kOAuthUrl/api/vote',
      body: 'id=$fullThingId&dir=-1'
    );
}
