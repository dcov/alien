part of 'saveable.dart';

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
