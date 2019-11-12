part of 'defaults.dart';

class InitDefaults extends Event {

  const InitDefaults({ @required this.defaults });

  final Defaults defaults;

  @override
  Event update(_) {
    defaults.refreshing = false;
    return LoadDefaults(defaults: defaults);
  }
}

class DisposeDefaults extends PopTarget {

  const DisposeDefaults({ @required this.defaults });

  final Defaults defaults;

  @override
  void update(_) {
    defaults..subreddits.clear()
            ..refreshing = false
            ..offset.value = 0.0;
  }
}

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
    // Ensure we're still expecting this.
    if (!defaults.refreshing)
      return;

    defaults
      ..refreshing = false
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)))
      ..subreddits.sort(compareSubreddits);
  }
}

