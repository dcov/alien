import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/subreddit.dart';
import '../models/subscriptions.dart';

import 'thing.dart';

part 'subscriptions.g.dart';

@event refreshSubscriptions(RootAuth root, { @required Subscriptions subscriptions }) {

  // If it's already refreshing we don't need to do anything.
  if (subscriptions.refreshing)
    return;

  subscriptions.refreshing = true;
  return GetSubscriptions(
    subscriptions: subscriptions,
    user: root.auth.currentUser
  );
}

@effect getSubscriptions(EffectContext context,
      { @required Subscriptions subscriptions, @required User user }) async {

  final RedditClient client = context.reddit.asUser(user.token);

  try {
    final List<SubredditData> result = List<SubredditData>();
    Pagination pagination = Pagination.maxLimit();

    do {
      final ListingData<SubredditData> listing = await client.getUserSubreddits(
        UserSubreddits.subscriber,
        pagination.nextPage,
        false
      );
      result.addAll(listing.things);
      pagination = pagination.forward(listing);
    } while(pagination.nextPageExists);

    return GetSubscriptionsSuccess(
      subscriptions: subscriptions,
      data: result
    );
  } catch (e) {
    print(e);
    return GetSubscriptionsFailure();
  }
}

@event getSubscriptionsSuccess(
    _, { @required Subscriptions subscriptions, @required List<SubredditData> data }) {

  subscriptions
    ..refreshing = false
    ..subreddits.clear()
    ..subreddits.addAll(
        data.map((SubredditData sd) => Subreddit.fromData(sd)))
    ..subreddits.sort((s1, s2) => s1.name.compareTo(s2.name));
}

@event getSubscriptionsFailure(_) {
  // TODO: implement
}

@event toggleSubscribed(RootAuth root, { @required Subreddit subreddit }) {

  final User user = root.auth.currentUser;
  assert(user != null);

  subreddit.userIsSubscriber = !subreddit.userIsSubscriber;

  if (subreddit.userIsSubscriber)
    return <Message>{
      RemoveSubscription(),
      PostUnsubscribe(
        subreddit: subreddit,
        user: user)
    };

  return <Message>{
    AddSubscription(),
    PostSubscribe(
      subreddit: subreddit,
      user: user)
  };
}


@event addSubscription(_) {
  // TODO: implement
}

@effect postSubscribe(EffectContext context, { @required Subreddit subreddit, @required User user }) async {
  try {
    await context.reddit
        .asUser(user.token)
        .postSubscribe(makeFullId(subreddit));
  } catch (_) {
    // TODO: error handling
  }
}

@event removeSubscription(_) {
 // TODO: Implement
}

@effect postUnsubscribe(EffectContext context, { @required Subreddit subreddit, @required User user }) async {
  try {
    await context.reddit
        .asUser(user.token)
        .postUnsubscribe(makeFullId(subreddit));
  } catch (_) {
    // TODO: error handling
  }
}

