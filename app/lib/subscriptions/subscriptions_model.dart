part of 'subscriptions.dart';

abstract class Subscriptions implements Model {

  factory Subscriptions() {
    return _$Subscriptions(
      refreshing: false,
      subreddits: const <Subreddit>[]
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits; 
}
