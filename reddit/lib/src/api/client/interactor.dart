part of '../client.dart';

class RedditInteractor extends EndpointInteractor
    with AnyEndpoints, IdentityEndpoints, MySubreddditsEndpoints,
         ReadEndpoints, SaveEndpoints, VoteEndpoints {

  RedditInteractor(this._client, this._store);

  final RedditClient _client;

  final TokenStore _store;

  Client get _ioClient => RedditClient._ioClient;

  String _extractBody(Response response) => response.body;

  @override
  Future<String> get(String url) async {
    return _ioClient.get(
      url,
      headers: await _store.tokenHeader,
    ).then(_extractBody);
  }

  @override
  Future<String> post(String url, [String body]) async {
    return _ioClient.post(
      url,
      body: body,
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }

  @override
  Future<String> patch(String url, [String body]) async {
    return _ioClient.patch(
      url,
      body: body,
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }

  @override
  Future<String> delete(String url) async {
    return _ioClient.delete(
      url,
      headers: await _store.tokenHeader
    ).then(_extractBody);
  }
}
