part of '../endpoints.dart';

mixin ReadEndpoints on EndpointInteractor {

  Future<ListingData<PostData>> getHomePosts(HomeSort sort, Page page) {
    return get('${_kOAuthUrl}/${sort}/${_kRawJsonArgs}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<ThingData>> getPostComments(String permalink, CommentsSort sort) {
    return get('${_kOAuthUrl}/${permalink}/${_kRawJsonArgs}&sort=${sort}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<PostData>> getPostsById(Iterable<String> fullPostIds) {
    return get('${_kOAuthUrl}/by_id/${fullPostIds.join(',')}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<PostData> getPostById(String fullPostId) {
    return getPostsById([fullPostId])
        .then((ListingData listing) {
          final Iterable<PostData> posts = listing.things;
          return posts.isNotEmpty ? posts.single : null;
        });
  }

  Future<ListingData<ThingData>> getMoreComments(String fullPostId, String moreId,
      Iterable<String> thingIds) {
    return get('${_kOAuthUrl}/api/morechildren/${_kRawJsonArgs}'
               '&link_id=${fullPostId}&id=${moreId}'
               '&children=${thingIds.join(',')}')
        .then((String json) {
          return ListingData.fromJson(json,
              (Map obj) => obj['data']['json']);
        });
  }

  Future<MultiData> getMultiByPath(String multiPath, bool expandSubreddits) {
    return get('${_kOAuthUrl}/api/multi/${multiPath}/'
               '?expand_srs=${expandSubreddits}')
        .then((String json) => MultiData.fromJson(json));
  }

  Future<ListingData<PostData>> getOriginalPosts(OriginalSort sort, Page page) {
    return get('${_kOAuthUrl}/original/${sort}/${_kRawJsonArgs}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<SubredditData> getSubredditByName(String subredditName) {
    return get('${_kOAuthUrl}/r/${subredditName}/about')
        .then((String json) => SubredditData.fromJson(json));
  }

  Future<Iterable<SubredditData>> getSubredditsByName(
      Iterable<String> subredditNames) async {
    final List<SubredditData> result = List<SubredditData>(subredditNames.length);
    for (final String subredditName in subredditNames) {
      final SubredditData data = await getSubredditByName(subredditName);
      result.add(data);
    }
    return result;
  }

  Future<ListingData<SubredditData>> getSubreddits(Subreddits where, Page page) {
    return get('${_kOAuthUrl}/subreddits/${where}/?${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<PostData>> getSubredditPosts(String subredditName,
      SubredditSort sort, Page page) {
    return get('${_kOAuthUrl}/r/${subredditName}/${sort}'
               '/${_kRawJsonArgs}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<Iterable<MultiData>> getMultisOfUser(String username,
      bool expandSubreddits) {
    return get('${_kOAuthUrl}/api/multi/user/${username}/'
               '?expand_srs=${expandSubreddits}')
        .then((String json) => MultiData.iterableFromJson(json));
  }

  Future<Iterable<SubredditData>> postSubredditSearch(String query, bool exact,
      bool includeOver18) {
    return post('${_kOAuthUrl}/api/search_subreddits',
        'query=${query}&exact=${exact}&include_over_18=${includeOver18}')
            .then((String json) => SubredditData.iterableFromJson(json));
  }
}
