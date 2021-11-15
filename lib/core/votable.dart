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

class Vote implements Update {

  Vote({
    required this.votable,
    required this.voteDir,
    this.user,
  }) : assert(voteDir != VoteDir.none);

  final Votable votable;

  final VoteDir voteDir;

  final User? user;

  @override
  Then update(AccountsOwner owner) {
    assert(user != null || owner.accounts.currentUser != null,
        'Tried to up/down vote without a User being signed in or manually selecting a User.');

    final oldVoteDir = votable.voteDir;
    switch (voteDir) {
      case VoteDir.up:
        switch (oldVoteDir) {
          case VoteDir.up:
            votable..score -= 1
                   ..voteDir = VoteDir.none;
            break;
          case VoteDir.down:
            votable..score += 2
                   ..voteDir = VoteDir.up;
            break;
          case VoteDir.none:
            votable..score += 1
                   ..voteDir = VoteDir.up;
            break;
        }
        break;
      case VoteDir.down:
        switch (oldVoteDir) {
          case VoteDir.up:
            votable..score -= 2
                   ..voteDir = VoteDir.down;
            break;
          case VoteDir.down:
            votable..score += 1
                   ..voteDir = VoteDir.none;
            break;
          case VoteDir.none:
            votable..score -= 1
                   ..voteDir = VoteDir.down;
        }
        break;
    }

    return Then(_PostVote(
      votable: votable,
      oldVoteDir: oldVoteDir,
      user: user ?? owner.accounts.currentUser!,
    ));
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
