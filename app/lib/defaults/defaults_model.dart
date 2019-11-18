part of 'defaults.dart';

abstract class Defaults implements Target {

  factory Defaults() {
    return _$Defaults(
      subreddits: const <Subreddit>[],
      offset: ScrollOffset(),
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits;

  ScrollOffset get offset;
}
