import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/post_comments.dart';
import '../models/more.dart';
import '../models/post_comments.dart';
import '../widgets/pressable.dart';

class MoreTile extends StatelessWidget {

  MoreTile({
    Key key,
    @required this.comments,
    @required this.more
  }) : super(key: key);

  final PostComments comments;

  final More more;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {

      void dispatchLoadMoreComments() {
        context.dispatch(
          LoadMoreComments(
            comments: comments,
            more: more));
      }

      final style = TextStyle(
        fontSize: 12.0,
        color: Colors.black54);

      return Pressable(
        onPress: !more.isLoading ? dispatchLoadMoreComments : () { },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.0 * (1 + more.depth),
            8.0,
            16.0,
            8.0),
          child: !more.isLoading
            ? Text('load ${more.count} comments', style: style)
            : Text('loading...', style: style)));
    });
}

