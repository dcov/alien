import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/votable.dart';

import 'thing.dart' show ThingExtensions;

part 'votes.msg.dart';

@action upvote(AuthOwner owner,
    { @required Votable votable, User user }) {

  final VoteDir oldVoteDir = votable.voteDir;

  if (votable.voteDir == VoteDir.up) {
    votable..score -= 1
           ..voteDir = VoteDir.none;
  } else {
    votable..score += votable.voteDir == VoteDir.down ? 2 : 1
           ..voteDir = VoteDir.up;
  }

  return PostVote(
    votable: votable,
    user: user ?? owner.auth.currentUser,
    oldVoteDir: oldVoteDir);
}

@action downvote(AuthOwner owner,
    { @required Votable votable, User user }) {

  final VoteDir oldVoteDir = votable.voteDir;

  if (votable.voteDir == VoteDir.down) {
    votable..score += 1
           ..voteDir = VoteDir.none;
  } else {
    votable..score -= votable.voteDir == VoteDir.up ? 2 : 1
           ..voteDir = VoteDir.down;
  }

  return PostVote(
    votable: votable,
    user: user ?? owner.auth.currentUser,
    oldVoteDir: oldVoteDir);
}

@effect postVote(EffectContext context,
    { @required Votable votable, @required User user, @required VoteDir oldVoteDir }) {

  return context.reddit
    .asUser(user.token)
    .postVote(votable.fullId, votable.voteDir)
    .catchError(() {
      return PostVoteFailure(
        votable: votable,
        oldVoteDir: oldVoteDir);
    });
}

@action postVoteFailure(_,
    { @required Votable votable, @required VoteDir oldVoteDir }) {

  switch (oldVoteDir) {
    // votable was previously not voted in any direction so we have to add or remove a point.
    case VoteDir.none:
      votable.score += votable.voteDir == VoteDir.down ? 1 : -1;
      break;
    // votable was previously upvoted so we have to add back points.
    case VoteDir.up:
      votable.score += votable.voteDir == VoteDir.none ? 1 : 2;
      break;
    // votable was previously downvoted so we have to remove points.
    case VoteDir.down:
      votable.score -= votable.voteDir == VoteDir.none ? 1 : 2;
  }
}

