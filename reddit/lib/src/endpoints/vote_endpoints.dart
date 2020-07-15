part of 'endpoints.dart';

extension VoteEndpoints on RedditClient {

  Future<void> postVote(String fullVotableId, VoteDir voteDir) {
    return post('/api/vote', body: 'id=${fullVotableId}&dir=${voteDir}');
  }
}

