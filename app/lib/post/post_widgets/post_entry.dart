part of '../post.dart';

class PostEntry extends TargetEntry {

  PostEntry({ @required this.post });

  final Post post;

  @override
  Target get target => post;

  @override
  String get title => post.title;

  @override
  Widget buildBody(BuildContext context) {
    return CommentsTreeScrollable(commentsTree: post.comments);
  }
}

