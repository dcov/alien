part of 'defaults.dart';

class GetDefaults extends Effect {

  const GetDefaults({ @required this.defaultsKey });

  final ModelKey defaultsKey;

  @override
  Future<Event> perform(Repo repo) {
    return repo
        .get<RedditClient>()
        .asDevice()
        .getSubreddits(
            Subreddits.defaults,
            Page(limit: Page.kMaxLimit))
        .then(
            (ListingData<SubredditData> listing) {
              return DefaultsLoaded(
                defaultsKey: this.defaultsKey,
                subreddits: listing.things
              );
            },
            onError: (e) {
            });
  }
}
