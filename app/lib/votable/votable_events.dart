part of 'votable.dart';

class Upvote extends Event {

  const Upvote({
    @required this.votable,
    this.user,
  });

  final Votable votable;

  final User user;

  @override
  Effect update(RootAuth root) {
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
      oldVoteDir: oldVoteDir,
      user: user ?? root.auth.currentUser,
    );
  }
}
