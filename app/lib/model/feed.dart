import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import '../model/listing.dart';
import '../model/post.dart';

part 'feed.g.dart';

enum Feed {
  home,
  popular,
  all
}

abstract class FeedPosts implements Model {

  factory FeedPosts({
    required Feed type,
    required RedditArg sortBy,
    TimeSort? sortFrom,
    required Listing<Post> listing,
  }) = _$FeedPosts;

  Feed get type;

  /// The value to use when sorting the posts.
  /// If [type] is [FeedType.home] this should be a [HomeSort] value; If [type] is [FeedType.popular] or [FeedType.all]
  /// this should be a [SubredditSort] value.
  RedditArg get sortBy;
  set sortBy(RedditArg value);

  /// Because both of the possible [sortBy] types ([HomeSort] and [SubredditSort]), are [TimedParameter]s, this is the
  /// time aspect to those sort values.
  TimeSort? get sortFrom;
  set sortFrom(TimeSort? value);

  Listing<Post> get listing;
}
