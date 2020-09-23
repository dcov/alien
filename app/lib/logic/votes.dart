import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/user.dart';
import '../models/votable.dart';

import 'thing.dart';
import 'user.dart';

class Upvote extends Action {

  Upvote({
    @required this.votable,
    this.user
  }) : assert(votable != null);

  final Votable votable;

  final User user;

  @override
  dynamic update(AccountsOwner owner) {
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
      user: user ?? owner.accounts.currentUser,
      oldVoteDir: oldVoteDir);
  }
}

class Downvote extends Action {

  Downvote({
    @required this.votable,
    this.user
  }) : assert(votable != null);

  final Votable votable;

  final User user;

  @override
  dynamic update(AccountsOwner owner) {
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
      oldVoteDir: oldVoteDir,
      user: user ?? owner.accounts.currentUser);
  }
}

class PostVote extends Effect {

  PostVote({
    @required this.votable,
    @required this.oldVoteDir,
    @required this.user,
  }) : assert(votable != null),
       assert(oldVoteDir != null),
       assert(user != null);

  final Votable votable;

  final VoteDir oldVoteDir;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .postVote(votable.fullId, votable.voteDir)
      .catchError(() {
        return PostVoteFailure(
          votable: votable,
          oldVoteDir: oldVoteDir);
      });
  }
}

class PostVoteFailure extends Action {

  PostVoteFailure({
    @required this.votable,
    @required this.oldVoteDir
  }) : assert(votable != null),
       assert(oldVoteDir != null);

  final Votable votable;

  final VoteDir oldVoteDir;

  @override
  dynamic update(_) {
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
}

