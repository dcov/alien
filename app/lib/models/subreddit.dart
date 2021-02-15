import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'listing.dart';
import 'post.dart';
import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit implements Model, Thing {

  factory Subreddit({
    bool userIsSubscriber,
    String name,
    String id,
    String kind,
  }) = _$Subreddit;

  String get name;

  bool userIsSubscriber;
}

abstract class SubredditPosts implements Model {

  factory SubredditPosts({
    Subreddit subreddit,
    SubredditSort sortBy,
    TimeSort sortFrom,
    Listing<Post> listing
  }) = _$SubredditPosts;

  Subreddit get subreddit;

  SubredditSort sortBy;

  TimeSort sortFrom;

  Listing<Post> get listing;
}

