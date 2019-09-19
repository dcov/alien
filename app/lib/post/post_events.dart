part of 'post.dart';

class PushPost extends PushTarget {

  const PushPost({ @required this.postKey });

  final ModelKey postKey;

  @override
  Event update(Store store) {
    final Post post = store.get(this.postKey);
    if (super.push(store, post)) {
      post.comments = CommentsTree(
        fullPostId: utils.makeFullId(post),
        permalink: post.permalink,
      );
      return RefreshCommentsTree(
        commentsTreeKey: post.comments.key
      );
    }
    return null;
  }
}

class PopPost extends PopTarget {

  const PopPost({ @required this.postKey });

  final ModelKey postKey;

  @override
  void update(Store store) {
    final Post post = store.get(this.postKey);
    super.pop(store, post);
    post.comments = null;
  }
}
