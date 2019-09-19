part of 'comments_tree.dart';

class RefreshCommentsTree extends Event {

  const RefreshCommentsTree({ @required this.commentsTreeKey });

  final ModelKey commentsTreeKey;

  @override
  Effect update(Store store) {
    final CommentsTree tree = store.get(this.commentsTreeKey);
    if (tree.isRefreshing)
      return null;

    tree..isRefreshing = true
        ..things.clear();
    
    return GetPostComments(
      commentsTreeKey: this.commentsTreeKey,
      permalink: tree.permalink,
      sort: tree.sort
    );
  }
}

class CommentsTreeRefreshed extends Event {

  const CommentsTreeRefreshed({
    @required this.commentsTreeKey,
    @required this.data
  });

  final ModelKey commentsTreeKey;

  final Iterable<ThingData> data;

  @override
  void update(Store store) {
    final CommentsTree tree = store.get(this.commentsTreeKey);
    assert(tree.isRefreshing);

    tree..isRefreshing = false
        ..things.addAll(this.data.map(_mapThing));
  }
}

class LoadMoreComments extends Event {

  LoadMoreComments({
    @required this.commentsTreeKey,
    @required this.moreKey,
  });

  final ModelKey commentsTreeKey;

  final ModelKey moreKey;

  @override
  Effect update(Store store) {
    final CommentsTree tree = store.get(this.commentsTreeKey);
    final More more = store.get(this.moreKey);
    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return GetMoreComments(
      commentsTreeKey: this.commentsTreeKey,
      moreKey: this.moreKey,
      fullPostId: tree.fullPostId,
      moreId: more.id,
      thingIds: more.thingIds,
    );
  }
}

class MoreCommentsLoaded extends Event {

  const MoreCommentsLoaded({
    @required this.commentsTreeKey,
    @required this.moreKey,
    @required this.data,
  });

  final ModelKey commentsTreeKey;

  final ModelKey moreKey;

  final Iterable<ThingData> data;

  @override
  void update(Store store) {
    final CommentsTree tree = store.get(this.commentsTreeKey);
    final More more = store.get(this.moreKey);
    assert(more.isLoading);

    more.isLoading = false;
    final int insertIndex = tree.things.indexOf(more);
    final Iterable<Thing> newThings = this.data.map(_mapThing);
    tree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}
