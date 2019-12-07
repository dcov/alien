part of 'subreddit.dart';

class InitSubreddit extends Event {

  InitSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.posts = SubredditPosts(
      subredditName: subreddit.name,
    );
    return LoadSubredditPosts(
      subredditPosts: subreddit.posts,
      status: ListingStatus.loadingFirst
    );
  }
}

class DisposeSubreddit extends Event {

  DisposeSubreddit({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.posts = null;
  }
}

class ToggleSubscribed extends Event {

  ToggleSubscribed({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(RootAuth root) {
    final User user = root.auth.currentUser;
    assert(user != null);

    subreddit.userIsSubscriber = !subreddit.userIsSubscriber;

    if (subreddit.userIsSubscriber)
      return <Message>{
        RemoveSubscription(subreddit: subreddit),
        PostUnsubscribe(
          subreddit: subreddit,
          user: user
        )
      };

    return <Message>{
      AddSubscription(subreddit: subreddit),
      PostSubscribe(
        subreddit: subreddit,
        user: user
      )
    };
  }
}

class AddSubscription extends ProxyEvent {

  AddSubscription({ @required this.subreddit });

  final Subreddit subreddit;
}

class RemoveSubscription extends ProxyEvent {

  RemoveSubscription({ @required this.subreddit });

  final Subreddit subreddit;
}

class PostSubscribeFail extends Event {

  PostSubscribeFail({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.userIsSubscriber = false;
  }
}

class PostUnsubscribeFail extends Event {

  PostUnsubscribeFail({ @required this.subreddit });

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.userIsSubscriber = true;
  }
}

