part of 'defaults.dart';

class RefreshDefaults extends Event {

  const RefreshDefaults({ @required this.defaultsKey });

  final ModelKey defaultsKey;

  @override
  Effect update(Store store) {
    final Defaults defaults = store.get(this.defaultsKey);
    if (defaults.refreshing)
      return null;
    
    defaults.refreshing = true;
    return GetDefaults(defaultsKey: this.defaultsKey);
  }
}

class UpdateDefaults extends Event {

  const UpdateDefaults({
    @required this.defaultsKey,
    @required this.subreddits
  });

  final ModelKey defaultsKey;

  final List<SubredditData> subreddits;

  @override
  void update(Store store) {
    store.get<Defaults>(this.defaultsKey)
      ..refreshing = false
      ..subreddits.clear()
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)));
  }
}
