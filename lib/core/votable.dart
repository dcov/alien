import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'accounts.dart';
import 'context.dart';
import 'thing.dart';
import 'user.dart';

abstract class Votable implements Thing {

  int get score;
  set score(int value);

  VoteDir get voteDir;
  set voteDir(VoteDir value);
}

class Upvote implements Update {

  Upvote({
    required this.votable,
    this.user
  });

  final Votable votable;

  final User? user;

  @override
  Then update(AccountsOwner owner) {
    assert(user != null || owner.accounts.currentUser != null,
        'Tried to upvote without providing a User or one being signed in.');

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
      oldVoteDir: oldVoteDir,
      user: user ?? owner.accounts.currentUser!));
  }
}

class Downvote implements Update {

  Downvote({
    required this.votable,
    this.user
  });

  final Votable votable;

  final User? user;

  @override
  Then update(AccountsOwner owner) {
    assert(user != null || owner.accounts.currentUser != null,
        'Tried to downvote without providing a User or one being signed in.');
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
        user: user ?? owner.accounts.currentUser!));
  }
}

class _PostVote implements Effect {

  _PostVote({
    required this.votable,
    required this.oldVoteDir,
    required this.user,
  });

  final Votable votable;

  final VoteDir oldVoteDir;

  final User user;

  @override
  Future<Then> effect(CoreContext context) {
    return context.clientFromUser(user)
      .postVote(votable.fullId, votable.voteDir)
      .then((_) => Then.done())
      .catchError((_) {
        return Then(_PostVoteFailed(
            votable: votable,
            oldVoteDir: oldVoteDir));
      });
  }
}

class _PostVoteFailed implements Update {

  _PostVoteFailed({
    required this.votable,
    required this.oldVoteDir
  });

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
