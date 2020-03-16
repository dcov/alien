import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';

import 'defaults_events.dart';
import 'defaults_model.dart';

class GetDefaults implements Effect {

  const GetDefaults({ @required this.defaults });

  final Defaults defaults;

  @override
  Future<Event> perform(EffectContext context) {
    return context.client
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
