part of 'endpoints.dart';

extension ReadEndpoints on RedditClient {

  Future<AccountData> getAccount(String username) {
    return get('/user/$username/about')
        .then((String json) => AccountData.fromJson(json));
  }

  Future<ListingData<PostData>> getHomePosts(Page page, HomeSort sortBy, [TimeSort sortFrom]) {
    return get('/${sortBy}/${_kRawJsonArgs}${_formatTimeSortAsArg(sortFrom)}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<ThingData>> getPostComments(String permalink, CommentsSort sort) {
    return get('/${permalink}/${_kRawJsonArgs}&sort=${sort}')
        .then((String json) {
          return ListingData.fromJson(json, (data) {
            return data[1]['data'];
          });
        });
  }

  Future<ListingData<PostData>> getPostsById(Iterable<String> fullPostIds) {
    return get('/by_id/${fullPostIds.join(',')}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<PostData> getPostById(String fullPostId) {
    return getPostsById([fullPostId])
        .then((ListingData listing) {
          final Iterable<PostData> posts = listing.things;
          return posts.isNotEmpty ? posts.single : null;
        });
  }

  Future<ListingData<ThingData>> getMoreComments(String fullPostId, String moreId, Iterable<String> thingIds) {
    return get('/api/morechildren/${_kRawJsonArgs}'
               '&api_type=json'
               '&link_id=${fullPostId}'
               '&id=${moreId}'
               '&children=${thingIds.join(',')}')
        .then((String json) {
          return ListingData.fromJson(json,
              (obj) => obj['json']['data']);
        });
  }

  Future<MultiData> getMultiByPath(String multiPath, bool expandSubreddits) {
    return get('/api/multi/${multiPath}/'
               '?expand_srs=${expandSubreddits}')
        .then((String json) => MultiData.fromJson(json));
  }

  Future<ListingData<PostData>> getOriginalPosts(OriginalSort sort, Page page) {
    return get('/original/${sort}/${_kRawJsonArgs}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<SubredditData> getSubredditByName(String subredditName) {
    return get('/r/${subredditName}/about')
        .then((String json) => SubredditData.fromJson(json));
  }

  Future<Iterable<SubredditData>> getSubredditsByName(Iterable<String> subredditNames) async {
    final List<SubredditData> result = List<SubredditData>(subredditNames.length);
    for (final String subredditName in subredditNames) {
      final SubredditData data = await getSubredditByName(subredditName);
      result.add(data);
    }
    return result;
  }

  Future<ListingData<SubredditData>> getSubreddits(Subreddits where, Page page) {
    return get('/subreddits/${where}/?${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<PostData>> getSubredditPosts(String subredditName, Page page, SubredditSort sortBy, [TimeSort sortFrom]) {
    return get('/r/${subredditName}/${sortBy}'
               '/${_kRawJsonArgs}${_formatTimeSortAsArg(sortFrom)}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<Iterable<MultiData>> getMultisOfUser(String username, bool expandSubreddits) {
    return get('/api/multi/user/${username}/'
               '?expand_srs=${expandSubreddits}')
        .then((String json) => MultiData.iterableFromJson(json));
  }

  Future<Iterable<SubredditData>> postSubredditSearch(String query, bool exact, bool includeOver18) {
    return post('/api/search_subreddits', body: 'query=${query}&exact=${exact}&include_over_18=${includeOver18}')
            .then((String json) => SubredditData.iterableFromJson(json));
  }
}

