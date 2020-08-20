import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/saveable.dart';
import '../models/user.dart';

import 'thing.dart' show ThingExtensions;

class ToggleSaved extends Action {

  ToggleSaved({
    @required this.saveable,
    this.user
  });

  final Saveable saveable;

  final User user;

  @override
  dynamic update(AuthOwner owner) {
    saveable.isSaved = !saveable.isSaved;
    return PostSaved(
      saveable: saveable,
      user: user ?? owner.auth.currentUser,
    );
  }
}

class PostSaved extends Effect {

  PostSaved({
    @required this.saveable,
    @required this.user
  });

  final Saveable saveable;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    final RedditClient client = context.reddit.asUser(user.token);
    try {
      if (saveable.isSaved) {
        client.postSave(saveable.fullId);
      } else {
        client.postUnsave(saveable.fullId);
      }
    } catch (_) {
      return PostSavedFailure(saveable: saveable);
    }
  }
}

class PostSavedFailure extends Action {

  PostSavedFailure({
    @required this.saveable
  });

  final Saveable saveable;

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

