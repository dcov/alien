part of 'defaults.dart';

abstract class Defaults extends Model {

  factory Defaults() {
    return _$Defaults(
      refreshing: false,
      subreddits: const <Subreddit>[]
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits;
}