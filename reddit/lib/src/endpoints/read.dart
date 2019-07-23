import 'dart:async';

import 'package:meta/meta.dart';

import 'package:reddit/client.dart';
import 'package:reddit/values.dart';
import 'package:reddit/convert.dart';

import 'interactor.dart';
import 'values.dart';

mixin ReadEndpointsMixin on EndpointInteractor {

  Future<Listing<Link>> getHomeLinks({
    @required HomeSort sort,
    @required Page page
  }) => get(
      scope: Scope.read,
      requiresBearer: true,
      url: '$kOAuthUrl/${sort.value}/$kRawJsonArg&$page'
    ).then(decodeLinkListing);

  Future<Listing<Thing>> getLinkComments({
    @required String permalink,
    @required CommentsSort sort
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/$permalink/$kRawJsonArg&sort=${sort.value}'
    ).then(decodeLinkComments);

  Future<Link> getLinkById({ @required String fullLinkId }) {
    return getLinksById(fullLinkIds: <String>[ fullLinkId ]).then((listing) {
      return listing.things.single;
    });
  }

  Future<Listing<Link>> getLinksById({
    @required Iterable<String> fullLinkIds
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/by_id/${fullLinkIds.join(',')}'
    ).then(decodeLinkListing);

  Future<Listing<Thing>> getMoreComments({
    @required String fullLinkId,
    @required String moreId,
    @required Iterable<String> thingIds
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/api/morechildren/$kRawJsonArg&api_type=json'
          '&link_id=$fullLinkId&id=$moreId&children=${thingIds.join(',')}'
    ).then(decodeMoreComments);

  Future<Multi> getMultiInfo({
    @required String multipath,
    @required bool expandSubreddits
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/api/multi/$multipath/?expand_srs=$expandSubreddits'
    ).then(decodeMulti);

  Future<Iterable<Multi>> getMyMultis({ @required bool expandSubreddits }) =>
    get(
      scope: Scope.read,
      requiresBearer: true,
      url: '$kOAuthUrl/api/multi/mine/?expand_srs=$expandSubreddits'
    ).then(decodeMultiIterable);

  Future<Listing<Link>> getOriginalLinks({
    @required OriginalSort sort,
    @required Page page,
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/original/${sort.value}/$kRawJsonArg&$page'
    ).then(decodeLinkListing);
  
  Future<Subreddit> getSubredditInfo({ @required String subredditName }) {
    return get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/r/$subredditName/about'
    ).then(decodeSubreddit);
  }

  Future<Iterable<Subreddit>> getSubredditInfos({ @required Iterable<String> subredditNames }) async {
    List<Subreddit> list = List<Subreddit>();
    for (final subredditName in subredditNames) {
      final Subreddit info = await getSubredditInfo(subredditName: subredditName);
      list.add(info);
    }
    return list;
  }

  Future<Listing<Subreddit>> getSubreddits({
    @required Subreddits where,
    @required Page page
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/subreddits/${where.value}/?$page'
    ).then(decodeSubredditListing);

  Future<Listing<Link>> getSubredditLinks({
    @required String subredditName,
    @required SubredditSort sort,
    @required Page page
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/r/$subredditName/${sort.value}/$kRawJsonArg&$page'
    ).then(decodeLinkListing);

  Future<Iterable<Multi>> getUserMultis({
    @required String username,
    @required bool expandSubreddits
  }) => get(
      scope: Scope.read,
      requiresBearer: false,
      url: '$kOAuthUrl/api/multi/user/$username/?expand_srs=$expandSubreddits'
    ).then(decodeMultiIterable);

  Future<Iterable<Subreddit>> postSearchSubreddits({
    @required String query,
    @required bool exact,
    @required bool includeOver18,
  }) => post(
    scope: Scope.read,
    requiresBearer: false,
    url: '$kOAuthUrl/api/search_subreddits',
    body: 'query=$query&exact=$exact&include_over_18=$includeOver18'
  ).then(decodeSubredditsList);
}