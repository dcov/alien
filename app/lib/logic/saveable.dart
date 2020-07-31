import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth_model.dart';
import '../models/saveable_model.dart';
import '../models/user_model.dart';
import '../utils/thing_utils.dart' as utils;

class ToggleSaved implements Event {

  ToggleSaved({
    @required this.saveable,
    this.user,
  });

  final Saveable saveable;

  final User user;

  @override
  Effect update(RootAuth root) {
    saveable.isSaved = !saveable.isSaved;
    return PostSaveable(
      saveable: saveable,
      user: user ?? root.auth.currentUser,
    );
  }
}

class PostSaveable implements Effect {

  PostSaveable({
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

