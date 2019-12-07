part of 'post.dart';

class InitPost extends Event {

  InitPost({ @required this.post });

  final Post post;

  @override
  Event update(_) {
    post.comments = CommentsTree(
      fullPostId: makeFullId(post),
      permalink: post.permalink,
    );
    return LoadCommentsTree(
      commentsTree: post.comments
    );
  }
}

class DisposePost extends Event {

  const DisposePost({ @required this.post });

  final Post post;

  @override
  void update(_) {
    post.comments = null;
  }
}
