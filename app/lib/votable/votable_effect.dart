part of 'votable.dart';

class PostVote extends Effect {

  PostVote({
    @required this.userToken,
    @required this.fullVotableId,
    @required this.newVoteDir,
    @required this.votableKey,
    @required this.oldVoteDir,
  });

  final String userToken;
  final String fullVotableId;
  final VoteDir newVoteDir;
  final ModelKey votableKey;
  final VoteDir oldVoteDir;

  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<RedditClient>()
      .asUser(userToken)
      .postVote(fullVotableId, newVoteDir)
      .catchError((e) {
      });
  }
}
