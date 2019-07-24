import 'package:loux/loux.dart';

class PostUpvote extends Effect {

  PostUpvote({
    this.fullId,
    this.key,
  });

  final String fullId;
  final ModelKey key;

  @override
  Future<Event> perform(Container container) {
    // TODO: Implement PostUpvote Effect
    return null;
  }
}

class PostDownvote extends Effect {

  PostDownvote({
    this.fullId,
    this.key
  });

  final String fullId;
  final ModelKey key;

  @override
  Future<Event> perform(Container container) {
    // TODO: Implement PostDownvote Effect
    return null;
  }
}

class PostUnvote extends Effect {

  PostUnvote({
    this.fullId,
    this.key
  });

  final String fullId;
  final ModelKey key;

  @override
  Future<Event> perform(Container container) {
    // TODO: Implement PostUnvote Effect
    return null;
  }
}
