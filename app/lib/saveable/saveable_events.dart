import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../auth/auth_model.dart';
import '../user/user_model.dart';

import 'saveable_effects.dart';
import 'saveable_model.dart';

class ToggleSaved extends Event {

  const ToggleSaved({
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
