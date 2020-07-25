import 'package:elmer/elmer.dart';

import 'subreddit_model.dart';

export 'subreddit_model.dart';

part 'defaults_model.g.dart';

abstract class Defaults implements Model {

  factory Defaults() {
    return _$Defaults(
      refreshing: false,
      subreddits: const <Subreddit>[]);
  }

  bool refreshing;

  List<Subreddit> get subreddits;
}

