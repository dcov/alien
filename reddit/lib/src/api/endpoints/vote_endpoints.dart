part of '../endpoints.dart';

mixin VoteEndpoints on EndpointInteractor {

  Future<void> postVote(String fullVotableId, VoteDir voteDir) {
    return post('${_kOAuthUrl}/api/vote',
        'id=${fullVotableId}&dir=${voteDir}');
  }
}
