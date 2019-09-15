part of 'subreddit.dart';

abstract class Subreddit extends Model implements Thing, RoutingTarget {

  factory Subreddit.fromData(SubredditData data) {
    return _$Subreddit(
      name: data.displayName
    );
  }

  String get name;
}
