import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/post_comments.dart';
import '../models/more.dart';
import '../models/post_comments.dart';

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

      return Padding(
        padding: EdgeInsets.only(left: 16.0 * more.depth),
        child: Material(
          child: InkWell(
            onTap: !more.isLoading ? dispatchLoadMoreComments : null,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: !more.isLoading
                ? Text('Load ${more.count} comments')
                : Text('Loading...')))));
    });
}

