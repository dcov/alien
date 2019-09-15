part of '../endpoints.dart';

mixin SubscribeEndpoints on EndpointInteractor {

  Future<void> postSubscribe(String fullSubredditId, bool subscribe) {
    final String action = subscribe ? 'sub' : 'unsub';
    return post('${_kOAuthUrl}/api/subscribe',
        'sr=$fullSubredditId&action=$action');
  }
}
