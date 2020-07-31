import 'package:elmer/elmer.dart';

import 'subreddit.dart';

export 'subreddit.dart';

part 'subscriptions.g.dart';

abstract class Subscriptions implements Model {

  factory Subscriptions() {
    return _$Subscriptions(
      refreshing: false,
      subreddits: const <Subreddit>[],
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits; 
}

