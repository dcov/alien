import 'package:meta/meta.dart';

@immutable
abstract class Reference { }

class ExternalReference implements Reference {
  ExternalReference(this.ref);
  final String ref;
}

class SubredditReference implements Reference {
  SubredditReference(this.subredditName);
  final String subredditName;
}

class AccountReference implements Reference {
  AccountReference(this.username);
  final String username;
}

class LinkReference implements Reference {
  LinkReference(this.linkId, this.permalink);
  final String linkId;
  final String permalink;
}

final RegExp _nameExp = RegExp(r'^[A-Za-z0-9]+/?$');
final RegExp _subredditPrefixExp = RegExp(r'^(/?r/)');
final RegExp _linkCommentsExp = RegExp(r'(comments)/[A-Za-z0-9]+/');
final RegExp _accountPrefixExp = RegExp(r'^(/?(u|user)/)');

Reference matchReference(String url) {

  final Uri uri = Uri.parse(url);

  if (uri.host == 'www.reddit.com' || uri.host?.isEmpty == true) {
    // Try to match to a reddit related thing
    String path = uri.path;
    Match match = _subredditPrefixExp.firstMatch(path);
    if (match != null) {
      /// It's either a SubredditReference or LinkReference
      path = path.substring(match.end);
      match = _nameExp.firstMatch(path);
      if (match != null) {
        /// It's a SubredditReference because the path ends with the name.
        return SubredditReference(match.group(0).replaceAll('/', ''));
      }

      match = _linkCommentsExp.firstMatch(path);
      if (match != null) {
        return LinkReference(
          match.group(0).replaceAll('comments/', '').replaceAll('/', ''),
          uri.path
        );
      }

      return ExternalReference(url);
    }

    match = _accountPrefixExp.firstMatch(path);
    if (match != null) {

      path = path.substring(match.end);
      match =_nameExp.firstMatch(path);
      if (match != null) {
        return AccountReference(match.group(0).replaceAll('/', ''));
      }

      return ExternalReference(url);
    }
  }

  return ExternalReference(url);
}