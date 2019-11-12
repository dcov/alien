part of 'saveable.dart';

class PostSaveable extends Effect {

  const PostSaveable({
     @required this.saveable,
     @required this.user
  });

  final Saveable saveable;

  final User user;

  @override
  Future<Event> perform(Deps deps) async {
    final RedditInteractor reddit = deps.client.asUser(user.token);
    return (saveable.isSaved
        ? reddit.postSave(makeFullId(saveable))
        : reddit.postUnsave(makeFullId(saveable)))
      .then((_) => null, onError: (_) => null);
  }
}
