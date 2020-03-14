import 'package:elmer/elmer.dart';

import '../subreddit/subreddit_model.dart';
import '../widgets/scroll_offset.dart';

part 'defaults_model.g.dart';

abstract class Defaults implements Model {

  factory Defaults() {
    return _$Defaults(
      refreshing: false,
      subreddits: const <Subreddit>[],
      offset: ScrollOffset(),
    );
  }

  bool refreshing;

  List<Subreddit> get subreddits;

  ScrollOffset get offset;
}
