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
  }) : assert(saveable != null);

  final Saveable saveable;

  final User user;

  @override
  dynamic update(AccountsOwner owner) {
    saveable.isSaved = !saveable.isSaved;
    return _PostSaved(
      saveable: saveable,
      user: user ?? owner.accounts.currentUser,
    );
  }
}

class _PostSaved extends Effect {

  _PostSaved({
    @required this.saveable,
    @required this.user
  }) : assert(saveable != null),
       assert(user != null);

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
      return _PostSavedFailed(saveable: saveable);
    }
  }
}

class _PostSavedFailed extends Action {

  _PostSavedFailed({
    @required this.saveable
  }) : assert(saveable != null);

  final Saveable saveable;

  @override
  dynamic update(_) {
    saveable.isSaved = !saveable.isSaved;
  }
}

