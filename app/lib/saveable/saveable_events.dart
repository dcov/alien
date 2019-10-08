part of 'saveable.dart';

class ToggleSaved extends Event {

  ToggleSaved({
    @required this.saveable,
    this.user,
  });

  final Saveable saveable;

  final User user;

  @override
  Effect update(AppState state) {
    saveable.isSaved = !saveable.isSaved;
    return PostSaveable(
      saveable: saveable,
      user: user ?? state.auth.currentUser,
    );
  }
}
