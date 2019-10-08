part of 'subscriptions.dart';

class RefreshSubscriptions extends Event {

  const RefreshSubscriptions({
    @required this.subscriptions,
    this.user,
  });

  final Subscriptions subscriptions;

  final User user;

  @override
  Effect update(AppState state) {
    // We're already refreshing, so we don't need to do anything.
    if (subscriptions.refreshing)
      return null;

    subscriptions.refreshing = true;
    return GetSubscriptions(
      subscriptions: this.subscriptions,
      user: user ?? state.auth.currentUser
    );
  }
}

class UpdateSubscriptions extends Event {

  const UpdateSubscriptions({
    @required this.subscriptions,
    @required this.subreddits,
  });

  final Subscriptions subscriptions;

  final List<SubredditData> subreddits;

  @override
  void update(_) {
    subscriptions
      ..refreshing = false
      ..subreddits.clear()
      ..subreddits.addAll(
        this.subreddits.map((data) => Subreddit.fromData(data)));
  }
}
