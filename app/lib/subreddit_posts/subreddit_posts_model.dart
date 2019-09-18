part of 'subreddit_posts.dart';

abstract class SubredditPosts extends Model implements Listing {

  factory SubredditPosts({
    @required String subredditName,
    SubredditSort sort = SubredditSort.hot
  }) {
    return _$SubredditPosts(
      subredditName: subredditName,
      sort: sort,
      mode: ListingMode.endless,
      status: ListingStatus.idle,
      things: const <Post>[],
      state: ListingState()
    );
  }

  String get subredditName;

  SubredditSort sort;
}
