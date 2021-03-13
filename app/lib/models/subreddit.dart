import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'listing.dart';
import 'post.dart';
import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit implements Model, Thing {

  factory Subreddit({
    int? bannerBackgroundColor,
    String? bannerImageUrl,
    String? iconImageUrl,
    required String name,
    int? primaryColor,
    required bool userIsSubscriber,
    required String id,
    required String kind,
  }) = _$Subreddit;

  int? get bannerBackgroundColor;
  set bannerBackgroundColor(int? value);

  String? get bannerImageUrl;
  set bannerImageUrl(String? value);

  String? get iconImageUrl;
  set iconImageUrl(String? value);

  String get name;

  int? get primaryColor;
  set primaryColor(int? value);

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
