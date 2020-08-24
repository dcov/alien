import 'package:elmer/elmer.dart';

import 'listing.dart';
import 'post.dart';

part 'feed.g.dart';

enum FeedType {
  home,
  popular,
  all
}

abstract class Feed extends Model {

  factory Feed({
    FeedType type,
    Object sortBy,
    Listing<Post> posts
  }) = _$Feed;

  FeedType get type;

  /// The value to use when sorting the posts.
  /// If [type] is [FeedType.home] this should be a [HomeSort] value; If [type] is [FeedType.popular] or [FeedType.all]
  /// this should be a [SubredditSort] value.
  Object sortBy;

  Listing<Post> posts;
}

