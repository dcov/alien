import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/subreddit.dart';
import '../models/subscriptions.dart';

import 'subreddit.dart' show SubredditDataExtensions;
import 'thing.dart' show ThingExtensions;

part 'subscriptions.msg.dart';

@action refreshSubscriptions(AuthOwner owner, { @required Subscriptions subscriptions }) {

  // If it's already refreshing we don't need to do anything.
  if (subscriptions.refreshing)
    return;

  subscriptions.refreshing = true;
  return GetSubscriptions(
    subscriptions: subscriptions,
    user: owner.auth.currentUser
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

@action getSubscriptionsSuccess(_,
    { @required Subscriptions subscriptions, @required List<SubredditData> data }) {

  subscriptions
    ..refreshing = false
    ..subreddits.clear()
    ..subreddits.addAll(
        data.map((SubredditData data) => data.toModel()))
    ..subreddits.sort((s1, s2) => s1.name.compareTo(s2.name));
}

@action getSubscriptionsFailure(_) {
  // TODO: implement
}

@action toggleSubscribed(AuthOwner owner, { @required Subreddit subreddit }) {

  final User user = owner.auth.currentUser;
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


@action addSubscription(_) {
  // TODO: implement
}

@effect postSubscribe(EffectContext context, { @required Subreddit subreddit, @required User user }) async {
  try {
    await context.reddit
        .asUser(user.token)
        .postSubscribe(subreddit.fullId);
  } catch (_) {
    // TODO: error handling
  }
}

@action removeSubscription(_) {
 // TODO: Implement
}

@effect postUnsubscribe(EffectContext context, { @required Subreddit subreddit, @required User user }) async {
  try {
    await context.reddit
        .asUser(user.token)
        .postUnsubscribe(subreddit.fullId);
  } catch (_) {
    // TODO: error handling
  }
}

