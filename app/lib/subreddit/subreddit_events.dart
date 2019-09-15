part of 'subreddit.dart';

class PushSubreddit extends TargetPush {

  const PushSubreddit({ @required this.subredditKey });

  final ModelKey subredditKey;

  @override
  void update(Store store) {
    final Subreddit subreddit = store.get(this.subredditKey);
    if (push(store, subreddit)) {
      
    }
  }
}
