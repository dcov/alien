import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/saveable.dart';
import '../logic/voting.dart';
import '../models/comment.dart';
import '../widgets/circle_divider.dart';
import '../widgets/formatting.dart';
import '../widgets/options_bottom_sheet.dart';
import '../widgets/pressable.dart';
import '../widgets/slidable.dart';
import '../widgets/tile.dart';

import 'snudown_body.dart';
import 'view_extensions.dart';
import 'votable_utils.dart';

void _showCommentOptionsBottomSheet({
    @required BuildContext context,
    @required Comment comment,
  }) {
  assert(context != null);
  showOptionsBottomSheet(
    context: context,
    options: <Option>[
      if (context.userIsSignedIn)
        Option(
          onSelected: () {
            context.dispatch(ToggleSaved(saveable: comment));
          },
          title: comment.isSaved ? 'Unsave' : 'Save',
          icon: comment.isSaved ? Icons.save : Icons.save_outlined)
    ]);
}

class CommentTile extends StatelessWidget {

  CommentTile({
    Key key,
    @required this.comment,
    @required this.includeDepthPadding
  }) : super(key: key);

  final Comment comment;

  final bool includeDepthPadding;

  Color get _authorColor {
    if (comment.distinguishment == "moderator") {
       return Colors.green;
    } else if (comment.isSubmitter) {
      return Colors.blue.shade900.withAlpha((80/100*255).round());
    } else {
      return Colors.black54;
    }
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Slidable(
        actions: <SlidableAction>[
          SlidableAction(
            onTriggered: () {
              context.dispatch(Upvote(votable: comment));
            },
            icon: Icons.arrow_upward,
            iconColor: Colors.white,
            backgroundColor: Colors.deepOrange,
            preBackgroundColor: Colors.grey),
          SlidableAction(
            onTriggered: () {
              context.dispatch(Downvote(votable: comment));
            },
            icon: Icons.arrow_downward,
            iconColor: Colors.white,
            backgroundColor: Colors.indigoAccent),
          SlidableAction(
            onTriggered: () {
              _showCommentOptionsBottomSheet(
                context: context,
                comment: comment);
            },
            icon: Icons.more_horiz,
            iconColor: Colors.white,
            backgroundColor: Colors.grey)
        ],
        child: Padding(
          padding: EdgeInsets.only(left: (comment.depth * 16.0) + 1),
          child: Material(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Pressable(
                onPress: () { },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: HorizontalCircleDivider.divide(<Widget>[
                        Text(
                          'u/${comment.authorName}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: _authorColor)),
                        Text(
                          formatElapsedUtc(comment.createdAtUtc),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54)),
                        Text(
                          '${formatCount(comment.score)} points',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: getVoteColor(comment))),
                        if (comment.editedAtUtc != null)
                          Text(
                            'edited ${formatElapsedUtc(comment.editedAtUtc)}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54)),
                      ])),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: SnudownBody(
                        snudown: comment.body,
                        scrollable: false))
                  ]))))));
    });
}

