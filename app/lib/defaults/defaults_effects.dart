part of 'defaults.dart';

class GetDefaults extends Effect {

  const GetDefaults({ @required this.defaultsKey });

  final ModelKey defaultsKey;

  @override
  Future<Event> perform(Repository repository) {
    return repository
        .get<RedditClient>()
        .asDevice()
        .getSubreddits(
            Subreddits.defaults,
            Page(limit: Page.kMaxLimit))
        .then(
            (ListingData<SubredditData> listing) {
              return UpdateDefaults(
                defaultsKey: this.defaultsKey,
                subreddits: listing.things
              );
            },
            onError: (e) {

            });
  }
}
