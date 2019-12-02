part of 'subreddit.dart';

abstract class Subreddit implements Thing, Target {

  factory Subreddit.fromData(SubredditData data) {
    return _$Subreddit(
      name: data.displayName,
      userIsSubscriber: data.userIsSubscriber,
    );
  }

  String get name;

  SubredditPosts posts;

  bool userIsSubscriber;
}
