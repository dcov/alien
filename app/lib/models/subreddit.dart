import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show SubredditData, SubredditSort;

import 'listing.dart';
import 'post.dart';

export 'listing.dart';
export 'post.dart';

part 'subreddit.g.dart';

abstract class Subreddit implements Thing {

  factory Subreddit.fromData(SubredditData data) {
    return _$Subreddit(
      name: data.displayName,
      userIsSubscriber: data.userIsSubscriber,
    );
  }

  String get name;

  Listing<Post> posts;

  SubredditSort sortBy;

  bool userIsSubscriber;
}
