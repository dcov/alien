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
  Action update(AccountsOwner owner) {
    assert(user != null || owner.accounts.currentUser != null,
        'Tried to up/down vote without a User being signed in or manually selecting a User.');

    final oldVoteDir = votable.voteDir;
    final oldScore = votable.score;
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

    return Effect((CoreContext context) {
      return context.clientFromUser(user)
        .postVote(votable.fullId, votable.voteDir)
        .then(
          (_) => None(),
          onError: (_) => Update((_) {
            // TODO: Something needs to be done here in the case where the
            // Votable object is updated elsewhere, in which case oldVoteDir
            // and oldScore may be outdated.
            votable..voteDir = oldVoteDir
                   ..score = oldScore;
            return None();
          }),
        );
    });
  }
}
