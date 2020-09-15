import 'package:elmer/elmer.dart';

import 'listing.dart';
import 'post.dart';

part 'feed.g.dart';

enum Feed {
  home,
  popular,
  all
}

abstract class FeedPosts extends Model {

  factory FeedPosts({
    Feed type,
    Object sortBy,
    Listing<Post> listing,
  }) = _$FeedPosts;

  Feed get type;

  /// The value to use when sorting the posts.
  /// If [type] is [FeedType.home] this should be a [HomeSort] value; If [type] is [FeedType.popular] or [FeedType.all]
  /// this should be a [SubredditSort] value.
  Object sortBy;

  Listing<Post> listing;
}

