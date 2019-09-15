part of 'votable.dart';

class Upvote extends Event {

  const Upvote({
    @required this.votableKey,
    this.userKey,
  }) : assert(votableKey != null);

  final ModelKey votableKey;

  final ModelKey userKey;

  @override
  Effect update(Store store) {
    final Votable votable = store.get(this.votableKey);
    final VoteDir oldVoteDir = votable.voteDir;

    if (votable.voteDir == VoteDir.up) {
      votable..score -= 1
             ..voteDir = VoteDir.none;
    } else {
      votable..score += votable.voteDir == VoteDir.down ? 2 : 1
             ..voteDir = VoteDir.up;
    }

    return PostVote(
      userToken: utils.getUserToken(store, this.userKey),
      fullVotableId: votable.fullId,
      newVoteDir: votable.voteDir,
      votableKey: votable.key,
      oldVoteDir: oldVoteDir
    );
  }
}
