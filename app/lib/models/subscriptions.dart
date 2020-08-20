import 'package:elmer/elmer.dart';

import 'subreddit.dart';

part 'subscriptions.g.dart';

abstract class Subscriptions extends Model {

  factory Subscriptions({
    bool refreshing,
    List<Subreddit> subreddits
  }) = _$Subscriptions;

  bool refreshing;

  List<Subreddit> get subreddits; 
}

abstract class SubscriptionsOwner {

  Subscriptions subscriptions;
}

