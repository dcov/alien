import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../thing/thing_utils.dart' as utils;
import '../user/user_model.dart';

import 'saveable_model.dart';

class PostSaveable extends Effect {

  const PostSaveable({
     @required this.saveable,
     @required this.user
  });

  final Saveable saveable;

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    final RedditClient client = context.reddit.asUser(user.token);
    return (saveable.isSaved
        ? client.postSave(utils.makeFullId(saveable))
        : client.postUnsave(utils.makeFullId(saveable)))
      .then((_) => null, onError: (_) => null);
  }
}
