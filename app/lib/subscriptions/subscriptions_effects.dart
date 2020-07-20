import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../user/user_model.dart';

import 'subscriptions_events.dart';
import 'subscriptions_model.dart';

class GetSubscriptions extends Effect {

  const GetSubscriptions({
    @required this.subscriptions,
    @required this.user,
  });

  final Subscriptions subscriptions;

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
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
        subscriptions: this.subscriptions,
        data: result
      );
    } catch (e) {
      print(e);
      return GetSubscriptionsFail();
    }
  }
}

