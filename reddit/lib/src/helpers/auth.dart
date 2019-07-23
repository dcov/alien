import 'dart:async';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:reddit/client.dart';
import 'package:reddit/convert.dart';
import 'package:reddit/values.dart';

class AuthSession {

  factory AuthSession(RedditClient client, Iterable<Scope> scopes) {

    final String state = Uuid().v4().toString().substring(0, 10);
    final String url =
      "$kAuthorizationUrl?client_id=${client.id}&response_type=code&state=$state"
      "&redirect_uri=${client.redirect}&duration=permanent"
      "&scope=${Scope.makeOAuthScope(scopes)}";

    return AuthSession._(url, state);
  }

  AuthSession._(this.url, this.state);

  final String url;
  final String state;
}

Future<RefreshToken> postCode({
  @required RedditClient client,
  @required String code
}) {
  return client.postCode(code: code).then(decodeRefreshToken);
}