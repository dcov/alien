part of 'post.dart';

class PushPost extends PushTarget {

  const PushPost({ @required this.post });

  final Post post;

  @override
  Event update(AppState state) {
    if (super.push(state.routing, post)) {
      post.comments = CommentsTree(
        fullPostId: makeFullId(post),
        permalink: post.permalink,
      );
      return RefreshCommentsTree(
        commentsTree: post.comments
      );
    }
    return null;
  }
}

class PopPost extends PopTarget {

  const PopPost({ @required this.post });

  final Post post;

  @override
  void update(AppState state) {
    super.pop(state.routing, post);
    // post.comments = null;
  }
}
