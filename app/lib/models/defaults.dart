import 'package:elmer/elmer.dart';

import 'subreddit.dart';

part 'defaults.g.dart';

abstract class Defaults extends Model {

  factory Defaults({
    bool refreshing,
    List<Subreddit> subreddits
  }) = _$Defaults;

  bool refreshing;

  List<Subreddit> get subreddits;
}

