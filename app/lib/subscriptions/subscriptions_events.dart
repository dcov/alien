part of 'subscriptions.dart';

class RefreshSubscriptions extends Event {

  const RefreshSubscriptions({
    @required this.subscriptions,
  });

  final Subscriptions subscriptions;

  @override
  Effect update(RootAuth root) {
    // We're already refreshing, so we don't need to do anything.
    if (subscriptions.refreshing)
      return null;

    subscriptions.refreshing = true;
    return GetSubscriptions(
      subscriptions: this.subscriptions,
      user: root.auth.currentUser
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

