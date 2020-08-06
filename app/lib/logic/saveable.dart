import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/saveable.dart';

import 'thing.dart' show ThingExtensions;

part 'saveable.msg.dart';

@action toggleSaved(AuthOwner owner, { @required Saveable saveable, User user }) {
  saveable.isSaved = !saveable.isSaved;
  return PostSaved(
    saveable: saveable,
    user: user ?? owner.auth.currentUser,
  );
}

@effect postSaved(EffectContext context, { @required Saveable saveable, @required User user }) async {
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

@action postSavedFailure(_, { @required Saveable saveable }) {
  // TODO: implement
}

