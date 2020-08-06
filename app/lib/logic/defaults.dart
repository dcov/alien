import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/defaults.dart';

import 'subreddit.dart' show SubredditDataExtensions;

part 'defaults.msg.dart';

@action loadDefaults(_, { @required Defaults defaults }) {
  if (defaults.refreshing)
    return null;
  
  defaults..refreshing = true
          ..subreddits.clear();

  return GetDefaults(defaults: defaults);
}

@effect getDefaults(EffectContext context, { @required Defaults defaults }) {
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
          return GetDefaultsFailed(defaults: defaults);
        });
}

@action getDefaultsSuccess(_, { @required Defaults defaults, @required Iterable<SubredditData> result }) {
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

@action getDefaultsFailed(_, { @required Defaults defaults }) {
  // TODO: implement
}

