import 'dart:async';
import 'package:meta/meta.dart';
import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';
import 'interactor.dart';
import 'values.dart';

mixin MySubredditsEndpointsMixin on EndpointInteractor {

  Future<Listing<Subreddit>> getMySubreddits({
    @required MySubreddits where,
    @required Page page,
    bool includeCategories = false,
  }) {
    return get(
      scope: Scope.mySubreddits,
      requiresBearer: true,
      url: '$kOAuthUrl/subreddits/mine/${where.value}/?$page&include_categories=$includeCategories'
    ).then(decodeSubredditListing);
  }
}