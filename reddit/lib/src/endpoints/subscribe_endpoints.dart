part of 'endpoints.dart';

extension SubscribeEndpoints on RedditClient {

  Future<void> postSubscribe(String fullSubredditId) {
    return post('/api/subscribe', body: 'sr=$fullSubredditId&action=sub');
  }

  Future<void> postUnsubscribe(String fullSubredditId) {
    return post('/api/subscribe', body: 'sr=$fullSubredditId&action=unsub');
  }
}

