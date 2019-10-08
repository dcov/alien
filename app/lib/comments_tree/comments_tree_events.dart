part of 'comments_tree.dart';

class RefreshCommentsTree extends Event {

  const RefreshCommentsTree({ @required this.commentsTree });

  final CommentsTree commentsTree;

  @override
  Effect update(_) {
    assert(commentsTree != null);
    if (commentsTree.isRefreshing)
      return null;

    commentsTree..isRefreshing = true
        ..things.clear();
    
    return GetPostComments(commentsTree: this.commentsTree);
  }
}

class RefreshedCommentsTree extends Event {

  const RefreshedCommentsTree({
    @required this.commentsTree,
    @required this.data
  });

  final CommentsTree commentsTree;

  final Iterable<ThingData> data;

  @override
  void update(_) {
    assert(commentsTree.isRefreshing);
    commentsTree..isRefreshing = false
        ..things.addAll(_expandTree(data).map(_mapThing));
  }
}

class LoadMoreComments extends Event {

  const LoadMoreComments({
    @required this.commentsTree,
    @required this.more,
  });

  final CommentsTree commentsTree;

  final More more;

  @override
  Effect update(_) {
    assert(commentsTree != null);
    assert(more != null);

    if (more.isLoading)
      return null;
    
    more.isLoading = true;
    return GetMoreComments(
      commentsTree: this.commentsTree,
      more: this.more,
    );
  }
}

class LoadedMoreComments extends Event {

  const LoadedMoreComments({
    @required this.commentsTree,
    @required this.more,
    @required this.data,
  });

  final CommentsTree commentsTree;

  final More more;

  final Iterable<ThingData> data;

  @override
  void update(_) {
    assert(more.isLoading);
    more.isLoading = false;
    final int insertIndex = commentsTree.things.indexOf(more);
    final Iterable<Thing> newThings = _expandTree(data).map(_mapThing);
    commentsTree.things.replaceRange(insertIndex, insertIndex + 1, newThings);
  }
}
