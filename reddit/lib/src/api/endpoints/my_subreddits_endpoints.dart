part of '../endpoints.dart';

mixin MySubreddditsEndpoints on EndpointInteractor {

  Future<ListingData> getMySubreddits(MySubreddits where, Page page,
      bool includeCategories) {
    return get('${_kOAuthUrl}/subreddits/mine/${where.value}/?${page}'
               '&include_categories=${includeCategories}')
        .then((String json) => ListingData.fromJson(json));
  }
}
