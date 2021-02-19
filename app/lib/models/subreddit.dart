import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'listing.dart';
import 'post.dart';
import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit implements Model, Thing {

  factory Subreddit({
    required bool userIsSubscriber,
    required String name,
    required String id,
    required String kind,
  }) = _$Subreddit;

  String get name;

  bool get userIsSubscriber;
  set userIsSubscriber(bool value);
}

abstract class SubredditPosts implements Model {

  factory SubredditPosts({
    required Subreddit subreddit,
    required SubredditSort sortBy,
    TimeSort sortFrom,
    required Listing<Post> listing
  }) = _$SubredditPosts;

  Subreddit get subreddit;

  SubredditSort get sortBy;
  set sortBy(SubredditSort value);

  TimeSort? get sortFrom;
  set sortFrom(TimeSort? value);

  Listing<Post> get listing;
}
