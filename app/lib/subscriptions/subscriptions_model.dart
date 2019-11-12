part of 'subscriptions.dart';

abstract class Subscriptions implements RoutingTarget {

  factory Subscriptions() {
    return _$Subscriptions(
      refreshing: false,
      subreddits: const <Subreddit>[],
      offset: ScrollOffset(),
      depth: 0
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits; 

  ScrollOffset get offset;
}
