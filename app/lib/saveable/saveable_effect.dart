part of 'saveable.dart';

class PostSave extends Effect {

  PostSave({
    this.fullId,
    this.key
  });

  final String fullId;
  final ModelKey key;

  @override
  Future<Event> perform(Repo repo) {
    return null;
  }
}

class PostUnsave extends Effect {

  PostUnsave({
    this.fullId,
    this.key
  });

  final String fullId;
  final ModelKey key;

  @override
  Future<Event> perform(Repo repo) {
    return null;
  }
}
