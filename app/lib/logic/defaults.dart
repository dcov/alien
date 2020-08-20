import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/defaults.dart';

import 'subreddit.dart' show SubredditDataExtensions;

class LoadDefaults extends Action {

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

class GetDefaults extends Effect {

  GetDefaults({
    @required this.defaults
  });

  final Defaults defaults;

  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asDevice()
      .getSubreddits(
          Subreddits.defaults,
          Page(limit: Page.kMaxLimit))
      .then(
          (ListingData<SubredditData> result) {
            return GetDefaultsSuccess(
              defaults: defaults,
              result: result.things
            );
          },
          onError: (e) {
            return GetDefaultsFailure(defaults: defaults);
          });
  }
}

class GetDefaultsSuccess extends Action {

  GetDefaultsSuccess({
    @required this.defaults,
    @required this.result
  });

  final Defaults defaults;

  final Iterable<SubredditData> result;

  @override
  dynamic update(_) {
    // Ensure we're still expecting this.
    if (!defaults.refreshing)
      return;

    defaults
      ..refreshing = false
      ..subreddits.addAll(
          result.map((SubredditData data) => data.toModel()))
      ..subreddits.sort((s1, s2) {
          return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
        });
  }
}

class GetDefaultsFailure extends Action {

  GetDefaultsFailure({
    @required this.defaults
  });

  final Defaults defaults;

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

