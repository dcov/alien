part of 'subreddit.dart';

abstract class Subreddit implements Thing, RoutingTarget {

  factory Subreddit.fromData(SubredditData data) {
    return _$Subreddit(
      name: data.displayName,
    );
  }

  String get name;

  SubredditPosts posts;
}
