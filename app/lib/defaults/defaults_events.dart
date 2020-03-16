import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../subreddit/subreddit_model.dart';

import 'defaults_effects.dart';
import 'defaults_model.dart';

class LoadDefaults implements Event {

  const LoadDefaults({ @required this.defaults });

  final Defaults defaults;

  @override
  dynamic update(_) {
    if (defaults.refreshing)
      return null;
    
    defaults..refreshing = true
            ..subreddits.clear();

    return GetDefaults(defaults: defaults);
  }
}

class GetDefaultsSuccess implements Event {

  const GetDefaultsSuccess({
    @required this.defaults,
    @required this.subreddits
  });

  final Defaults defaults;

  final Iterable<SubredditData> subreddits;

  @override
  dynamic update(_) {
    // Ensure we're still expecting this.
    if (!defaults.refreshing)
      return;

    defaults
      ..refreshing = false
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)))
      ..subreddits.sort((s1, s2) => s1.name.compareTo(s2.name));
  }
}

class GetDefaultsFailed implements Event {

  const GetDefaultsFailed({ @required this.defaults });

  final Defaults defaults;

  @override
  dynamic update(_) { }
}

