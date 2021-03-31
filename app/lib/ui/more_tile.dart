import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../logic/post_comments.dart';
import '../model/more.dart';
import '../model/post_comments.dart';
import '../ui/pressable.dart';
import '../ui/theming.dart';

class MoreTile extends StatelessWidget {

  MoreTile({
    Key? key,
    required this.comments,
    required this.more
  }) : super(key: key);

  final PostComments comments;

  final More more;

  void _dispatchLoadMoreComments(BuildContext context) {
    context.then(
      Then(LoadMoreComments(
        comments: comments,
        more: more)));
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Connector(
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(left: (more.depth * 16.0) + 1),
          child: Material(
            color: theming.canvasColor,
            child: Pressable(
              onPress: !more.isLoading
                  ? () => _dispatchLoadMoreComments(context)
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: !more.isLoading
                  ? Text('load ${more.count} comments', style: theming.detailText)
                  : Text('loading...', style: theming.detailText)))));
      });
  }
}
