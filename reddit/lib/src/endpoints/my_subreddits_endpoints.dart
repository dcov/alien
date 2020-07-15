part of 'endpoints.dart';

extension MySubreddditsEndpoints on RedditClient {

  Future<ListingData<SubredditData>> getUserSubreddits(UserSubreddits where, Page page,
      bool includeCategories) {
    return get('/subreddits/mine/${where}/?${page}'
               '&include_categories=${includeCategories}')
        .then((String json) => ListingData.fromJson(json));
  }
}

