part of 'defaults.dart';

class LoadDefaults extends Event {

  const LoadDefaults({ @required this.defaultsKey });

  final ModelKey defaultsKey;

  @override
  Effect update(Store store) {
    final Defaults defaults = store.get(this.defaultsKey);
    if (defaults.refreshing)
      return null;
    
    defaults..refreshing = true
            ..subreddits.clear();
    return GetDefaults(defaultsKey: this.defaultsKey);
  }
}

class DefaultsLoaded extends Event {

  const DefaultsLoaded({
    @required this.defaultsKey,
    @required this.subreddits
  });

  final ModelKey defaultsKey;

  final Iterable<SubredditData> subreddits;

  @override
  void update(Store store) {
    store.get<Defaults>(this.defaultsKey)
      ..refreshing = false
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)))
      ..subreddits.sort(utils.compareSubreddits);
  }
}
