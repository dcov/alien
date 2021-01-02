import 'package:mal/mal.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/user.dart';
import '../models/votable.dart';

import 'thing.dart';
import 'user.dart';

class Upvote implements Update {

  Upvote({
    @required this.votable,
    this.user
  }) : assert(votable != null);

  final Votable votable;

  final User user;

  @override
  Then update(AccountsOwner owner) {
    final VoteDir oldVoteDir = votable.voteDir;

    if (votable.voteDir == VoteDir.up) {
      votable..score -= 1
             ..voteDir = VoteDir.none;
    } else {
      votable..score += votable.voteDir == VoteDir.down ? 2 : 1
             ..voteDir = VoteDir.up;
    }

    return Then(_PostVote(
      votable: votable,
      user: user ?? owner.accounts.currentUser,
      oldVoteDir: oldVoteDir));
  }
}

class Downvote implements Update {

  Downvote({
    @required this.votable,
    this.user
  }) : assert(votable != null);

  final Votable votable;

  final User user;

  @override
  Then update(AccountsOwner owner) {
    final VoteDir oldVoteDir = votable.voteDir;

    if (votable.voteDir == VoteDir.down) {
      votable..score += 1
             ..voteDir = VoteDir.none;
    } else {
      votable..score -= votable.voteDir == VoteDir.up ? 2 : 1
             ..voteDir = VoteDir.down;
    }

    return Then(_PostVote(
      votable: votable,
      oldVoteDir: oldVoteDir,
      user: user ?? owner.accounts.currentUser));
  }
}

class _PostVote implements Effect {

  _PostVote({
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
  Future<Then> effect(EffectContext context) {
    return context.clientFromUser(user)
      .postVote(votable.fullId, votable.voteDir)
      .then((_) => Then.done())
      .catchError((_) {
        return _PostVoteFailed(
          votable: votable,
          oldVoteDir: oldVoteDir);
      });
  }
}

class _PostVoteFailed implements Update {

  _PostVoteFailed({
    @required this.votable,
    @required this.oldVoteDir
  }) : assert(votable != null),
       assert(oldVoteDir != null);

  final Votable votable;

  final VoteDir oldVoteDir;

  @override
  Then update(_) {
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
        break;
    }

    return Then.done();
  }
}

