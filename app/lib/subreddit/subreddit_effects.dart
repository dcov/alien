part of 'subreddit.dart';

class PostSubscribe extends Effect {

  PostSubscribe({
    @required this.userToken,
    @required this.fullSubredditId,
    @required this.subscribe,
  });

  final String userToken;
  final String fullSubredditId;
  final bool subscribe;

  @override
  void perform(Repository repository) {
    repository
        .get<RedditClient>()
        .asUser(userToken)
        .postSubscribe(fullSubredditId, subscribe);
  }
}