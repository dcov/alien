import 'package:meta/meta.dart';

@immutable
abstract class Link { }

class ExternalLink implements Link {
  ExternalLink(this.ref);
  final String ref;
}

class SubredditLink implements Link {
  SubredditLink(this.subredditName);
  final String subredditName;
}

class AccountLink implements Link {
  AccountLink(this.username);
  final String username;
}

class PostLink implements Link {
  PostLink(this.postId, this.permalink);
  final String postId;
  final String permalink;
}

final _nameExp = RegExp(r'^[A-Za-z0-9]+/?$');
final _subredditPrefixExp = RegExp(r'^(/?r/)');
final _postCommentsExp = RegExp(r'(comments)/[A-Za-z0-9]+/');
final _accountPrefixExp = RegExp(r'^(/?(u|user)/)');

Link matchLink(String url) {

  final Uri uri = Uri.parse(url);

  if (uri.host == 'www.reddit.com' || uri.host.isEmpty) {
    // Try to match to a reddit related thing
    var path = uri.path;
    var match = _subredditPrefixExp.firstMatch(path);
    if (match != null) {
      /// It's either a SubredditReference or LinkReference
      path = path.substring(match.end);
      match = _nameExp.firstMatch(path);
      if (match != null) {
        /// It's a SubredditReference because the path ends with the name.
        return SubredditLink(match.group(0)!.replaceAll('/', ''));
      }

      match = _postCommentsExp.firstMatch(path);
      if (match != null) {
        return PostLink(
          match.group(0)!.replaceAll('comments/', '').replaceAll('/', ''),
          uri.path
        );
      }

      return ExternalLink(url);
    }

    match = _accountPrefixExp.firstMatch(path);
    if (match != null) {

      path = path.substring(match.end);
      match =_nameExp.firstMatch(path);
      if (match != null) {
        return AccountLink(match.group(0)!.replaceAll('/', ''));
      }

      return ExternalLink(url);
    }
  }

  return ExternalLink(url);
}
