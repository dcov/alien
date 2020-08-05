import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show SubredditSort;

import 'listing.dart';
import 'post.dart';

export 'listing.dart';
export 'post.dart';

part 'subreddit.mdl.dart';

@model
mixin $Subreddit implements Thing {

  String get name;

  $Listing<$Post> posts;

  SubredditSort sortBy;

  bool userIsSubscriber;
}

