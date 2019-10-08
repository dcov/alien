part of 'votable.dart';

class PostVote extends Effect {

  PostVote({
    @required this.votable,
    @required this.user,
    @required this.oldVoteDir,
  });

  final Votable votable;
  final User user;
  final VoteDir oldVoteDir;

  @override
  Future<Event> perform(AppContainer container) {
    return container.client
      .asUser(user.token)
      .postVote(makeFullId(votable), votable.voteDir)
      .catchError((e) {
      });
  }
}
