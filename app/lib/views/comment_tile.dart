import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart';

import '../logic/saveable.dart';
import '../logic/voting.dart';
import '../models/comment.dart';
import '../utils/formatting.dart';
import '../widgets/circle_divider.dart';
import '../widgets/options_bottom_sheet.dart';
import '../widgets/pressable.dart';
import '../widgets/slidable.dart';

import 'snudown_body.dart';
import 'view_extensions.dart';
import 'votable_utils.dart';

void _showCommentOptionsBottomSheet({
    required BuildContext context,
    required Comment comment,
  }) {
  showOptionsBottomSheet(
    context: context,
    options: <Option>[
      if (context.userIsSignedIn)
        Option(
          onSelected: () {
            context.then(Then(ToggleSaved(saveable: comment)));
          },
          title: comment.isSaved ? 'Unsave' : 'Save',
          icon: comment.isSaved ? Icons.save : Icons.save_outlined)
    ]);
}

class CommentTile extends StatelessWidget {

  CommentTile({
    Key? key,
    required this.comment,
    required this.includeDepthPadding,
    this.collapsed = false,
    this.onCollapse,
    this.onCollapseToRoot,
    this.onUncollapse
  }) : assert(!collapsed ||
              (onCollapse != null &&
               onCollapseToRoot != null &&
               onUncollapse != null)),
       super(key: key);

  final Comment comment;

  final bool includeDepthPadding;

  final bool collapsed;

  final VoidCallback? onCollapse;
  
  final VoidCallback? onCollapseToRoot;

  final VoidCallback? onUncollapse;

  Color get _authorColor {
    if (comment.distinguishment == "moderator") {
       return Colors.green;
    } else if (comment.isSubmitter) {
      return Colors.blue.shade900.withAlpha((80/100*255).round());
    } else {
      return Colors.black54;
    }
  }

  Widget _addInsets(Widget child) {
    child = Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: child));

    if (includeDepthPadding)
      child = Padding(
        padding: EdgeInsets.only(left: (comment.depth! * 16.0) + 1),
        child: child);

    return child;
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      if (collapsed) {
        return _addInsets(Pressable(
          onPress: onUncollapse!,
          onLongPress: onCollapseToRoot!,
          child: Wrap(
            spacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: HorizontalCircleDivider.divide(<Widget>[
              Text(
                'u/${comment.authorName}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54)),
              Text(
                formatElapsedUtc(comment.createdAtUtc),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54)),
              Text(
                '[+]',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54))
            ]))));
      }

      Widget child = Column(
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
                  color: getVotableColor(comment))),
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
        ]);

      if (onCollapse != null) {
        child = Pressable(
          onLongPress: onCollapse!,
          child: child);
      }

      return Slidable(
        actions: <SlidableAction>[
          if (context.userIsSignedIn)
            ...[
              SlidableAction(
                onTriggered: () {
                  context.then(Then(Upvote(votable: comment)));
                },
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.white,
                backgroundColor: getVoteDirColor(VoteDir.up),
                preBackgroundColor: Colors.grey),
              SlidableAction(
                onTriggered: () {
                  context.then(Then(Downvote(votable: comment)));
                },
                icon: Icons.arrow_downward,
                iconColor: Colors.white,
                backgroundColor: getVoteDirColor(VoteDir.down)),
            ],
          SlidableAction(
            onTriggered: () {
              _showCommentOptionsBottomSheet(
                context: context,
                comment: comment);
            },
            icon: Icons.more_horiz,
            iconColor: Colors.white,
            backgroundColor: Colors.black54,
            preBackgroundColor: Colors.grey)
        ],
        child: _addInsets(child));
    });
}
