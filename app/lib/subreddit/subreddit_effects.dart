import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../effects/effect_context.dart';
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
      await context.client
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
      await context.client
          .asUser(user.token)
          .postUnsubscribe(utils.makeFullId(subreddit));
    } catch (_) {
      return PostUnsubscribeFail(subreddit: subreddit);
    }
  }
}

