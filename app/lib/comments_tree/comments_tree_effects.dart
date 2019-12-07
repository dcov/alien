part of 'comments_tree.dart';

class GetPostComments extends Effect {

  const GetPostComments({ @required this.commentsTree });

  final CommentsTree commentsTree;

  @override
  Future<Event> perform(EffectContext context) {
    return context.client
        .asDevice()
        .getPostComments(
          commentsTree.permalink,
          commentsTree.sort)
        .then(
          (ListingData<ThingData> data) {
            return GetPostCommentsSuccess(
              commentsTree: this.commentsTree,
              data: data.things
            );
          },
          onError: (_) {
            return GetPostCommentsFail();
          });
  }
}

class GetMoreComments extends Effect {

  const GetMoreComments({
    @required this.commentsTree,
    @required this.more,
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  Future<Event> perform(EffectContext context) {
    return context.client
        .asDevice()
        .getMoreComments(
          commentsTree.fullPostId,
          more.id,
          more.thingIds)
        .then(
          (ListingData<ThingData> data) {
            return GetMoreCommentsSuccess(
              commentsTree: this.commentsTree,
              more: this.more,
              data: data.things
            );
          },
          onError: (e) {
            return GetPostCommentsFail();
          });
  }
}

