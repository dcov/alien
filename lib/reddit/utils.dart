import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'types.dart';

const _kAuthorizationUrl = r'https://www.reddit.com/api/v1/authorize.compact';

class AuthSession {

  factory AuthSession(String clientId, String redirectUri, Iterable<String> scopes) {
    final String state = Uuid().v4().toString().substring(0, 10);
    final String url = '$_kAuthorizationUrl'
                       '?client_id=$clientId'
                       r'&response_type=code'
                       '&state=$state'
                       '&redirect_uri=$redirectUri'
                       r'&duration=permanent'
                       '${scopes.isNotEmpty
                            ? '&scope=${scopes.join('+')}'
                            : ''}';
    return AuthSession._(url, state);
  }

  AuthSession._(this.url, this.state);

  final String url;
  final String state;
}

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

enum _PaginationState {
  normal,
  before,
}

// Tracks a handful of variables needed to page through listings.
class Pagination {

  factory Pagination.maxLimit() {
    return Pagination(limit: Page.kMaxLimit);
  }

  factory Pagination({ int limit = Page.kDefaultLimit }) {
    limit = math.min(math.max(limit, 0), Page.kMaxLimit);
    return Pagination._(
      limit: limit,
      count: 0,
      nextPage: Page.next(limit: limit),
      previousPage: null,
      state: _PaginationState.normal
    );
  }
  
  Pagination._({
    required this.limit,
    required this.count,
    this.nextPage,
    this.previousPage,
    required this.state
  });

  final int limit;
  final int count;
  final Page? nextPage;
  final Page? previousPage;
  final _PaginationState state;

  bool get nextPageExists => nextPage != null;
  bool get previousPageExists => previousPage != null;

  Page? _buildNextPage(ListingData listing, int count) {
    if (listing.nextId != null)
      return Page.next(limit: limit, count: count, id: listing.nextId!);
    return null;
  }
  
  Page? _buildPreviousPage(ListingData listing, int count) {
    if (listing.previousId != null)
      return Page.previous(limit: limit, count: count, id: listing.previousId!);
    return null;
  }

  Pagination forward(ListingData listing) {
    final int newCount = (){
      switch (state) {
        case _PaginationState.normal:
          return this.count + this.limit;
        case _PaginationState.before:
          return this.count - 1;
        default:
          throw StateError('PaginationState is null');
      }
    }();
    return Pagination._(
      limit: limit,
      count: newCount,
      nextPage: _buildNextPage(listing, newCount),
      previousPage: _buildPreviousPage(listing, newCount),
      state: _PaginationState.normal
   );
  }

  Pagination backward(ListingData listing) {
    final int newCount = () {
      switch (state) {
        case _PaginationState.normal:
          return count + 1;
        case _PaginationState.before:
          return count - limit;
        default:
          throw StateError('PaginationState is null');
      }
    }();
    return Pagination._(
      limit: limit,
      count: newCount,
      nextPage: _buildNextPage(listing, newCount),
      previousPage: _buildPreviousPage(listing, newCount),
      state: _PaginationState.before
    );
  }
}