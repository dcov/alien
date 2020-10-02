import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../widgets/circle_divider.dart';
import '../widgets/formatting.dart';

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
      return Colors.blue.shade900.withAlpha((80/100*255).round());
     } else if (comment.distinguishment == "moderator") {
       return Colors.green;
     }
    return Colors.black54;
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Material(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.0 * (includeDepthPadding ? 1 + comment.depth : 1),
            8.0,
            16.0,
            8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: HorizontalCircleDivider.divide(<Widget>[
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: getAuthorColor(context))),
                  Text(
                    formatElapsedUtc(comment.createdAtUtc),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54)),
                  Text(
                    formatCount(comment.score),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54)),
                ])),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: SnudownBody(
                  snudown: comment.body,
                  scrollable: false))
            ])));
    });
}

