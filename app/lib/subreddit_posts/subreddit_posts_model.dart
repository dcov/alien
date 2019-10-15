part of 'subreddit_posts.dart';

abstract class SubredditPosts implements Listing {

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
      offset: ScrollOffset()
    );
  }

  String get subredditName;

  SubredditSort sort;
}
