import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';
import 'interactor.dart';
import 'values.dart';

mixin PrivateMessagesEndpointsMixin on EndpointInteractor {

  Future<Listing<Message>> getReceivedMessages({ @required Page page }) =>
    get(
      scope: Scope.privateMessages,
      requiresBearer: true,
      url: '$kOAuthUrl/message/inbox/?$page'
    ).then(decodeMessageListing);

  Future<Listing<Message>> getSentMessages({ @required Page page }) =>
    get(
      scope: Scope.privateMessages,
      requiresBearer: true,
      url: '$kOAuthUrl/message/sent/?$page'
    ).then(decodeMessageListing);
}