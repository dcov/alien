part of 'defaults.dart';

class LoadDefaults extends Event {

  const LoadDefaults({ @required this.defaults });

  final Defaults defaults;

  @override
  Effect update(_) {
    if (defaults.refreshing)
      return null;
    
    defaults..refreshing = true
            ..subreddits.clear();
    return GetDefaults(defaults: defaults);
  }
}

class DefaultsLoaded extends Event {

  const DefaultsLoaded({
    @required this.defaults,
    @required this.subreddits
  });

  final Defaults defaults;

  final Iterable<SubredditData> subreddits;

  @override
  void update(_) {
    defaults
      ..refreshing = false
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)))
      ..subreddits.sort(compareSubreddits);
  }
}
