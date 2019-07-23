import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';
import 'interactor.dart';
import 'values.dart';

mixin HistoryEndpointsMixin on EndpointInteractor {
  
  Future<Listing<Thing>> getUserHistory({
    @required String username,
    @required UserHistory where,
    @required HistorySort sort,
    @required Page page
  }) => get(
      scope: Scope.history,
      requiresBearer: false,
      url: '$kOAuthUrl/user/$username/${where.value}/?$page&sort=${sort.value}'
    ).then(decodeThingListing);

  Future<Listing<Thing>> getMyHistory({
    @required String username,
    @required MyHistory where,
    @required HistorySort sort,
    @required Page page
  }) => get(
      scope: Scope.history,
      requiresBearer: true,
      url: '$kOAuthUrl/user/$username/${where.value}/?$page&sort=${sort.value}'
    ).then(decodeThingListing);
}