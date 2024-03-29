import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';

import 'context.dart';
import 'accounts.dart';
import 'thing.dart';
import 'user.dart';

abstract class Saveable implements Thing {

  bool get isSaved;
  set isSaved(bool value);
}

class ToggleSaved implements Update {

  ToggleSaved({
    required this.saveable,
    this.user
  });

  final Saveable saveable;

  final User? user;

  @override
  Action update(AccountsOwner owner) {
    assert(user != null || owner.accounts.currentUser != null,
        'Tried to save a Thing without providing a User or one being signed in.');
    saveable.isSaved = !saveable.isSaved;
    return _PostSaved(
      saveable: saveable,
      user: user ?? owner.accounts.currentUser!,
    );
  }
}

class _PostSaved implements Effect {

  _PostSaved({
    required this.saveable,
    required this.user
  });

  final Saveable saveable;

  final User user;

  @override
  Future<Action> effect(CoreContext context) async {
    try {
      if (saveable.isSaved) {
        context.clientFromUser(user).postSave(saveable.fullId);
      } else {
        context.clientFromUser(user).postUnsave(saveable.fullId);
      }
      return None();
    } catch (_) {
      return _PostSavedFailed(saveable: saveable);
    }
  }
}

class _PostSavedFailed implements Update {

  _PostSavedFailed({
    required this.saveable
  });

  final Saveable saveable;

  @override
  Action update(_) {
    saveable.isSaved = !saveable.isSaved;
    return None();
  }
}
