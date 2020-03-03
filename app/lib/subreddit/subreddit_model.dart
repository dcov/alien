import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show SubredditData, SubredditSort;

import '../listing/listing_model.dart';
import '../post/post_model.dart';
import '../thing/thing_model.dart';

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
