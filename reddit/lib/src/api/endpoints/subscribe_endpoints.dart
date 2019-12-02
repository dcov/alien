part of '../endpoints.dart';

mixin SubscribeEndpoints on EndpointInteractor {

  Future<void> postSubscribe(String fullSubredditId) {
    return post(
        '${_kOAuthUrl}/api/subscribe',
        'sr=$fullSubredditId&action=sub'
    );
  }

  Future<void> postUnsubscribe(String fullSubredditId) {
    return post(
        '${_kOAuthUrl}/api/subscribe',
        'sr=$fullSubredditId&action=unsub'
    );
  }
}
