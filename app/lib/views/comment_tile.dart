import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../widgets/formatting.dart';
import '../widgets/insets.dart';

import 'snudown_body.dart';

class CommentTile extends StatelessWidget {

  CommentTile({
    Key key,
    @required this.comment,
    @required this.includeDepthPadding
  }) : super(key: key);

  final Comment comment;

  final bool includeDepthPadding;

  Color getAuthorColor(BuildContext context) {
    if (comment.isSubmitter) {
      return Colors.blue;
    }
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Material(
        child: Padding(
          padding: includeDepthPadding
            ? paddingWithLeftDepth(16.0, comment.depth)
            : const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(children: <Widget>[
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      color: getAuthorColor(context))),
                  Text(formatElapsedUtc(comment.createdAtUtc)),
                  Text(formatCount(comment.score)),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyText2,
                  child: SnudownBody(
                    snudown: comment.body,
                    scrollable: false)))
            ])));
    }
  );
}
