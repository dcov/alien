import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../listing/listing_model.dart' show ListingStatus;
import '../subreddit/subreddit_model.dart';
import '../thing/thing_utils.dart' as utils;
import '../user/user_model.dart';

import 'subreddit_events.dart';

class PostSubscribe extends Effect {

  PostSubscribe({
    @required this.subreddit,
    @required this.user,
  });

  final Subreddit subreddit;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postSubscribe(utils.makeFullId(subreddit));
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
  dynamic perform(EffectContext context) async {
    try {
      await context.reddit
          .asUser(user.token)
          .postUnsubscribe(utils.makeFullId(subreddit));
    } catch (_) {
      return PostUnsubscribeFail(subreddit: subreddit);
    }
  }
}

class GetSubredditPosts extends Effect {

  const GetSubredditPosts({
    @required this.subreddit,
    @required this.newStatus,
    @required this.page,
  });

  final Subreddit subreddit;

  final ListingStatus newStatus;

  final Page page;
  
  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asDevice()
      .getSubredditPosts(
        subreddit.name, subreddit.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return GetSubredditPostsSuccess(
            subreddit: subreddit,
            expectedStatus: newStatus,
            result: data);
        },
        onError: (_) {
          return GetSubredditPostsFail();
        });
  }
}

