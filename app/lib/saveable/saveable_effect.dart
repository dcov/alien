part of 'saveable.dart';

class PostSaveable extends Effect {

  const PostSaveable({
     @required this.saveable,
     @required this.user
  });

  final Saveable saveable;

  final User user;

  @override
  Future<Event> perform(EffectContext context) async {
    final RedditInteractor reddit = context.client.asUser(user.token);
    return (saveable.isSaved
        ? reddit.postSave(makeFullId(saveable))
        : reddit.postUnsave(makeFullId(saveable)))
      .then((_) => null, onError: (_) => null);
  }
}
