import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/defaults.dart';

import 'subreddit.dart' show SubredditDataExtensions;

class RefreshDefaults extends Action {

  RefreshDefaults();

  @override
  dynamic update(DefaultsOwner owner) {
    final defaults = owner.defaults;
    if (defaults.refreshing)
      return null;
    
    defaults..refreshing = true
            ..subreddits.clear();

    return GetDefaults();
  }
}

class GetDefaults extends Effect {

  GetDefaults();

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
              result: result.things);
          },
          onError: (e) {
            return GetDefaultsFailure();
          });
  }
}

class GetDefaultsSuccess extends Action {

  GetDefaultsSuccess({
    @required this.result
  });

  final Iterable<SubredditData> result;

  @override
  dynamic update(DefaultsOwner owner) {
    final defaults = owner.defaults;
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

  GetDefaultsFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

