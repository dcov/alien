part of 'subreddit.dart';

class PostSubscribe extends Effect {

  PostSubscribe({
    @required this.subreddit,
    @required this.user,
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(Deps deps) async {
    try {
      await deps.client
          .asUser(user.token)
          .postSubscribe(makeFullId(subreddit));
    } catch (_) {
      return PostSubscribeFail(subreddit: subreddit);
    }
  }
}

class PostUnsubscribe extends Effect {

  PostUnsubscribe({
    @required this.subreddit,
    @required this.user,
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(Deps deps) async {
    try {
      await deps.client
          .asUser(user.token)
          .postUnsubscribe(makeFullId(subreddit));
    } catch (_) {
      return PostUnsubscribeFail(subreddit: subreddit);
    }
  }
}

