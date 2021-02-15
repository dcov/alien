import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'listing.dart';
import 'post.dart';

part 'feed.g.dart';

enum Feed {
  home,
  popular,
  all
}

abstract class FeedPosts implements Model {

  factory FeedPosts({
    Feed type,
    Parameter sortBy,
    Listing<Post> listing,
  }) = _$FeedPosts;

  Feed get type;

  /// The value to use when sorting the posts.
  /// If [type] is [FeedType.home] this should be a [HomeSort] value; If [type] is [FeedType.popular] or [FeedType.all]
  /// this should be a [SubredditSort] value.
  Parameter sortBy;

  /// Because both of the possible [sortBy] types ([HomeSort] and [SubredditSort]), are [TimedParameter]s, this is the
  /// time aspect to those sort values.
  TimeSort sortFrom;

  Listing<Post> listing;
}

