import 'package:muex/muex.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/saveable.dart';
import '../models/user.dart';

import 'thing.dart';
import 'user.dart';

class ToggleSaved implements Update {

  ToggleSaved({
    @required this.saveable,
    this.user
  }) : assert(saveable != null);

  final Saveable saveable;

  final User user;

  @override
  Then update(AccountsOwner owner) {
    saveable.isSaved = !saveable.isSaved;
    return Then(_PostSaved(
      saveable: saveable,
      user: user ?? owner.accounts.currentUser,
    ));
  }
}

class _PostSaved implements Effect {

  _PostSaved({
    @required this.saveable,
    @required this.user
  }) : assert(saveable != null),
       assert(user != null);

  final Saveable saveable;

  final User user;

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      if (saveable.isSaved) {
        context.clientFromUser(user).postSave(saveable.fullId);
      } else {
        context.clientFromUser(user).postUnsave(saveable.fullId);
      }
      return Then.done();
    } catch (_) {
      return Then(_PostSavedFailed(saveable: saveable));
    }
  }
}

class _PostSavedFailed implements Update {

  _PostSavedFailed({
    @required this.saveable
  }) : assert(saveable != null);

  final Saveable saveable;

  @override
  Then update(_) {
    saveable.isSaved = !saveable.isSaved;
    return Then.done();
  }
}

