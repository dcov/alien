import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../comments_tree/comments_tree_events.dart';
import '../comments_tree/comments_tree_model.dart';
import '../thing/thing_utils.dart' as utils;

import 'post_model.dart';

class InitPost extends Event {

  InitPost({ @required this.post });

  final Post post;

  @override
  Event update(_) {
    post.comments = CommentsTree(
      fullPostId: utils.makeFullId(post),
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
