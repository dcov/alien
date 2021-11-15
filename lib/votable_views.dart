import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/votable.dart';
import 'reddit/types.dart';
import 'widgets/clickable.dart';
import 'widgets/formatting.dart';

import 'presentation_extensions.dart';

class VoteButton extends StatelessWidget {

  VoteButton({
    Key? key,
    required this.votable,
    required this.voteDir,
  }) : assert(voteDir != VoteDir.none),
       super(key: key);

  final Votable votable;

  final VoteDir voteDir;

  @override
  Widget build(_) => Connector(builder: (BuildContext context) {
    return Clickable(
      onClick: context.userIsSignedIn
        ? () => context.then(Then(Vote(votable: votable, voteDir: voteDir)))
        : null,
      child: voteDir == VoteDir.up
        ?  Icon(
            Icons.arrow_drop_up_rounded,
            color: votable.voteDir == VoteDir.up ? Colors.orange : Colors.grey,
            size: 24.0,
          )
        : Icon(
            Icons.arrow_drop_down_rounded,
            color: votable.voteDir  == VoteDir.down ? Colors.purple : Colors.grey,
            size: 24.0,
          ),
    );
  });
}

class ScoreText extends StatelessWidget {

  ScoreText({
    Key? key,
    required this.votable,
  }) : super(key: key);

  final Votable votable;

  @override
  Widget build(_) => Connector(builder: (BuildContext context) {
    return Text(
      formatCount(votable.score),
      maxLines: 1,
      overflow: TextOverflow.fade,
      style: TextStyle(
        color: votable.voteDir == VoteDir.up ? Colors.orange :
               votable.voteDir == VoteDir.down ? Colors.purple : null,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
      ),
    );
  });
}
