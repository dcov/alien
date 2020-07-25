import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/defaults_model.dart';

class LoadDefaults implements Event {

  LoadDefaults({
    @required this.defaults
  });

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

  GetDefaultsSuccess({
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
      ..subreddits.sort((s1, s2) {
          return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
        });
  }
}

class GetDefaultsFailed implements Event {

  GetDefaultsFailed({
    @required this.defaults
  });

  final Defaults defaults;

  @override
  dynamic update(_) { }
}

class GetDefaults implements Effect {

  GetDefaults({
    @required this.defaults
  });

  final Defaults defaults;

  @override
  Future<Event> perform(EffectContext context) {
    return context.reddit
        .asDevice()
        .getSubreddits(
            Subreddits.defaults,
            Page(limit: Page.kMaxLimit))
        .then(
            (ListingData<SubredditData> listing) {
              return GetDefaultsSuccess(
                defaults: defaults,
                subreddits: listing.things
              );
            },
            onError: (e) {
              return GetDefaultsFailed(defaults: defaults);
            });
  }
}
