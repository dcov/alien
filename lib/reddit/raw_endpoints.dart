import 'client.dart';
import 'types.dart';

const String kJsonArgs = '.json?raw_json=1';

String formatTimeSortAsArg(TimeSort? sortFrom, [String prefix='&']) {
  if (sortFrom == null)
    return '';
  return '${prefix}t=$sortFrom';
}

/// These are endpoints which are used by bin/json_analyzer.dart, and that as
/// a result only return the raw json instead of converting it to a predefined
/// data type.
///
/// endpoints.dart contains the endpoints used by the application, and uses these
/// in its own implementation.
extension RawRedditEndpoints on RedditClient {

  Future<String> getScopes([Iterable<Scope> scopes = const <Scope>[]]) {
    final args = scopes.isNotEmpty ? '?scopes=${scopes.join(' ')}' : '';
    return get('/api/v1/scopes${args}');
  }

  Future<String> getMe() {
    return get('/api/v1/me');
  }

  Future<String> getAccount(String username) {
    return get('/user/$username/about');
  }

  Future<String> getSubreddit(String subredditName) {
    return get('/r/${subredditName}/about');
  }

  Future<List<String>> getSubreddits(Iterable<String> subredditNames) async {
    final result = <String>[];
    for (final sn in subredditNames) {
      result.add(await getSubreddit(sn));
    }
    return result;
  }

  Future<String> getSubredditPosts(
      String subredditName, Page page, SubredditSort sortBy, [TimeSort? sortFrom]) {
    return get('/r/${subredditName}/${sortBy}'
               '/${kJsonArgs}${formatTimeSortAsArg(sortFrom)}&${page}');
  }

  Future<String> getMulti(String multipath, [ bool expandSubreddits = true]) {
    return get('/api/multi/${multipath}/?expand_srs=${expandSubreddits}');
  }

  Future<String> getPostComments(String permalink, CommentsSort sortBy) {
    return get('/${permalink}/${kJsonArgs}&sort=${sortBy}');
  }

  Future<String> getUserSubreddits(UserSubreddits where, Page page, bool includeCategories) {
    return get('/subreddits/mine/${where}/?${page}'
               '&include_categories=${includeCategories}');
  }
}
