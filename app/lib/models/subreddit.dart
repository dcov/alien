import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'listing.dart';
import 'post.dart';
import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit extends Model implements Thing {

  factory Subreddit({
    bool userIsSubscriber,
    String name,
    String id,
    String kind,
  }) = _$Subreddit;

  String get name;

  bool userIsSubscriber;
}

abstract class SubredditPosts extends Model {

  factory SubredditPosts({
    Subreddit subreddit,
    SubredditSort sortBy,
    Listing<Post> listing
  }) = _$SubredditPosts;

  Subreddit get subreddit;

  SubredditSort sortBy;

  Listing<Post> get listing;
}

