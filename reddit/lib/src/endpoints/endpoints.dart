import '../client/client.dart';
import '../types/args.dart';
import '../types/data.dart';

import 'raw_endpoints.dart';

extension RedditEndpoints on RedditClient {

  Future<Iterable<ScopeData>> getScopes([Iterable<Scope> scopes = const <Scope>[]]) {
    return RawRedditEndpoints(this).getScopes(scopes)
        .then((String json) => ScopeData.iterableFromJson(json));
  }

  Future<AccountData> getMe() {
    return RawRedditEndpoints(this).getMe()
        .then((String json) => AccountData.fromJson(json));
  }

  Future<ListingData<SubredditData>> getUserSubreddits(UserSubreddits where, Page page,
      bool includeCategories) {
    return get('/subreddits/mine/${where}/?${page}'
               '&include_categories=${includeCategories}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<AccountData> getAccount(String username) {
    return RawRedditEndpoints(this).getAccount(username)
        .then((String json) => AccountData.fromJson(json));
  }

  Future<ListingData<PostData>> getHomePosts(Page page, HomeSort sortBy, [TimeSort? sortFrom]) {
    return get('/${sortBy}/${kJsonArgs}${formatTimeSortAsArg(sortFrom)}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<ThingData>> getPostComments(String permalink, CommentsSort sortBy) {
    return RawRedditEndpoints(this).getPostComments(permalink, sortBy)
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

  Future<PostData?> getPostById(String fullPostId) {
    return getPostsById([fullPostId])
        .then((ListingData listing) {
          if (listing.things.isNotEmpty)
            return listing.things.single as PostData;
          return null;
        });
  }

  Future<ListingData<ThingData>> getMoreComments(String fullPostId, String moreId, Iterable<String> thingIds) {
    return get('/api/morechildren/${kJsonArgs}'
               '&api_type=json'
               '&link_id=${fullPostId}'
               '&id=${moreId}'
               '&children=${thingIds.join(',')}')
        .then((String json) {
          return ListingData.fromJson(json,
              (obj) => obj['json']['data']);
        });
  }

  Future<MultiData> getMulti(String multipath, bool expandSubreddits) {
    return RawRedditEndpoints(this).getMulti(multipath, expandSubreddits)
        .then((String json) => MultiData.fromJson(json));
  }

  Future<ListingData<PostData>> getOriginalPosts(OriginalSort sort, Page page) {
    return get('/original/${sort}/${kJsonArgs}&${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<SubredditData> getSubreddit(String subredditName) {
    return RawRedditEndpoints(this).getSubreddit(subredditName)
        .then((String json) => SubredditData.fromJson(json));
  }

  Future<Iterable<SubredditData>> getSubreddits(Iterable<String> subredditNames) async {
    return RawRedditEndpoints(this).getSubreddits(subredditNames)
        .then((List<String> result) =>
            result.map((String json) =>
                SubredditData.fromJson(json)));
  }

  Future<ListingData<SubredditData>> getSubredditsWhere(Subreddits where, Page page) {
    return get('/subreddits/${where}/?${page}')
        .then((String json) => ListingData.fromJson(json));
  }

  Future<ListingData<PostData>> getSubredditPosts(String subredditName, Page page, SubredditSort sortBy, [TimeSort? sortFrom]) {
    return RawRedditEndpoints(this).getSubredditPosts(subredditName, page, sortBy, sortFrom)
        .then((String json) => ListingData.fromJson(json));
  }

  Future<Iterable<MultiData>> getUserMultis(String username, bool expandSubreddits) {
    return get('/api/multi/user/${username}/'
               '?expand_srs=${expandSubreddits}')
        .then((String json) => MultiData.iterableFromJson(json));
  }

  Future<Iterable<SubredditData>> postSubredditSearch(String query, bool exact, bool includeOver18) {
    return post('/api/search_subreddits', body: 'query=${query}&exact=${exact}&include_over_18=${includeOver18}')
            .then((String json) => SubredditData.iterableFromJson(json));
  }

  Future<void> postSave(String fullSaveableId) {
    return post('/api/save', body: 'id=${fullSaveableId}');
  }

  Future<void> postUnsave(String fullSaveableId) {
    return post('/api/unsave', body: 'id=${fullSaveableId}');
  }

  Future<void> postSubscribe(String fullSubredditId) {
    return post('/api/subscribe', body: 'sr=$fullSubredditId&action=sub');
  }

  Future<void> postUnsubscribe(String fullSubredditId) {
    return post('/api/subscribe', body: 'sr=$fullSubredditId&action=unsub');
  }

  Future<void> postVote(String fullVotableId, VoteDir voteDir) {
    return post('/api/vote', body: 'id=${fullVotableId}&dir=${voteDir}');
  }
}
