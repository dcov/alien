import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/post.dart';
import 'core/post_comments.dart';
import 'widgets/page_router.dart';

import 'post_comments_slivers.dart';

class PostPage extends PageEntry {

  PostPage({ required this.post }) : super(key: ValueKey(post));

  final Post post;
  late final PostComments _comments;

  @override
  void initState(BuildContext context) {
    _comments = commentsFromPost(post);
    context.then(Then(RefreshPostComments(comments: _comments)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      AppBar(
        leading: CloseButton(),
        title: Text("Comments"),
      ),
      Expanded(child: CustomScrollView(
        slivers: <Widget>[
          PostCommentsTreeSliver(comments: _comments),
        ]
      )),
    ]);
  }
}
