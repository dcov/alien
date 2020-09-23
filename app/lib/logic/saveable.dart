import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/saveable.dart';
import '../models/user.dart';

import 'thing.dart';
import 'user.dart';

class ToggleSaved extends Action {

  ToggleSaved({
    @required this.saveable,
    this.user
  });

  final Saveable saveable;

  final User user;

  @override
  dynamic update(AccountsOwner owner) {
    saveable.isSaved = !saveable.isSaved;
    return PostSaved(
      saveable: saveable,
      user: user ?? owner.accounts.currentUser,
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
    try {
      if (saveable.isSaved) {
        context.clientFromUser(user).postSave(saveable.fullId);
      } else {
        context.clientFromUser(user).postUnsave(saveable.fullId);
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

