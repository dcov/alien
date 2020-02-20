import 'package:elmer/elmer.dart';

import '../subreddit/subreddit_model.dart';
import '../widgets/scroll_offset.dart';

part 'subscriptions_model.g.dart';

abstract class Subscriptions implements Model {

  factory Subscriptions() {
    return _$Subscriptions(
      refreshing: false,
      subreddits: const <Subreddit>[],
      offset: ScrollOffset(),
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits; 

  ScrollOffset get offset;
}
