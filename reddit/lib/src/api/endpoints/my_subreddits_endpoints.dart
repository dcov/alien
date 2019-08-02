part of '../endpoints.dart';

mixin MySubreddditsEndpoints on EndpointInteractor {

  Future<ListingData> getUserSubreddits(UserSubreddits where, Page page,
      bool includeCategories) {
    return get('${_kOAuthUrl}/subreddits/mine/${where}/?${page}'
               '&include_categories=${includeCategories}')
        .then((String json) => ListingData.fromJson(json));
  }
}
