import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show SubredditData, SubredditSort;

import 'listing_model.dart';
import 'post_model.dart';
import 'thing_model.dart';

export 'listing_model.dart';
export 'post_model.dart';
export 'thing_model.dart';

part 'subreddit_model.g.dart';

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
