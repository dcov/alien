part of 'comments_tree.dart';

class GetPostComments extends Effect {

  const GetPostComments({
    @required this.commentsTreeKey,
    @required this.permalink,
    @required this.sort,
  });

  final ModelKey commentsTreeKey;

  final String permalink;

  final CommentsSort sort;

  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<RedditClient>()
      .asDevice()
      .getPostComments(
        permalink,
        sort)
      .then(
        (ListingData<ThingData> data) {
          return CommentsTreeRefreshed(
            commentsTreeKey: this.commentsTreeKey,
            data: data.things
          );
        },
        onError: (e) {
          // TODO: error handling
        }
      );
  }
}

class GetMoreComments extends Effect {

  const GetMoreComments({
    @required this.commentsTreeKey,
    @required this.moreKey,
    @required this.fullPostId,
    @required this.moreId,
    @required this.thingIds
  });

  final ModelKey commentsTreeKey;

  final ModelKey moreKey;

  final String fullPostId;

  final String moreId;

  final Iterable<String> thingIds;

  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<RedditClient>()
      .asDevice()
      .getMoreComments(
        fullPostId,
        moreId,
        thingIds)
      .then(
        (ListingData<ThingData> data) {
          return MoreCommentsLoaded(
            commentsTreeKey: this.commentsTreeKey,
            moreKey: this.moreKey,
            data: data.things
          );
        },
        onError: (e) {
          // TODO: Handle errors
        });
  }
}
