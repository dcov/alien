part of 'defaults.dart';

class GetDefaults extends Effect {

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
              return DefaultsLoaded(
                defaults: defaults,
                subreddits: listing.things
              );
            },
            onError: (e) {
            });
  }
}
