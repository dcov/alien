import 'package:reddit/reddit.dart' show SubredditSort;
import 'package:meta/meta.dart';

import '../listing/listing_model.dart';
import '../post/post_model.dart';
import '../widgets/scroll_offset.dart';

part 'subreddit_posts_model.g.dart';

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
