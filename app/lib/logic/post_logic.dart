import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../models/comments_tree_model.dart';
import '../models/post_model.dart';
import '../utils/thing_utils.dart' as utils;

import 'comments_tree_logic.dart';

class InitPost implements Event {

  InitPost({
    @required this.post
  });

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

class DisposePost implements Event {

  const DisposePost({
    @required this.post
  });

  final Post post;

  @override
  void update(_) {
    post.comments = null;
  }
}

