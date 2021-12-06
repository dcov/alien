import 'package:flutter/material.dart' hide Action, Page;
import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'context.dart';
import 'accounts.dart';
import 'listing.dart';
import 'thing_store.dart';
import 'user.dart';

part 'feed.g.dart';

enum FeedKind {
  home,
  popular,
  all
}

abstract class Feed implements Model {

  factory Feed({ required FeedKind kind }) {

    late RedditArg sortBy;
    switch (kind) {
      case FeedKind.home:
        sortBy = HomeSort.best;
        break;
      case FeedKind.popular:
      case FeedKind.all:
        sortBy = SubredditSort.hot;
    }

    return _$Feed(
      kind: kind,
      sortBy: sortBy,
      listing: Listing(),
    );
  }

  factory Feed.raw({
    required FeedKind kind,
    required RedditArg sortBy,
    TimeSort? sortFrom,
    required Listing listing,
  }) = _$Feed;

  FeedKind get kind;

  /// The value to use when sorting the posts.
  /// If [type] is [FeedType.home] this should be a [HomeSort] value; If [type] is [FeedType.popular] or [FeedType.all]
  /// this should be a [SubredditSort] value.
  RedditArg get sortBy;
  set sortBy(RedditArg value);

  /// Because both of the possible [sortBy] types ([HomeSort] and [SubredditSort]), are [TimedParameter]s, this is the
  /// time aspect to those sort values.
  TimeSort? get sortFrom;
  set sortFrom(TimeSort? value);

  Listing get listing;
}

class TransitionFeed implements Update {

  TransitionFeed({
    required this.feed,
    required this.to,
    this.sortBy,
    this.sortFrom
  });

  final Feed feed;

  final ListingStatus to;

  final RedditArg? sortBy;

  final TimeSort? sortFrom;

  @override
  Action update(AccountsOwner owner) {
    assert(feed.kind != FeedKind.home || owner.accounts.currentUser != null,
        'Tried to load the home feed without a signed in user');

    bool changedSort = false;
    if (sortBy != null && sortBy != feed.sortBy)  {
      // Since we're changing the sort value, we should be refreshing
      assert(to == ListingStatus.refreshing);
      feed.sortBy = sortBy!;

      changedSort = true;
    }

    if (sortFrom != null && sortFrom != feed.sortFrom) {
      assert(to == ListingStatus.refreshing);
      feed.sortFrom = sortFrom!;
      changedSort = true;
    }

    if (feed.sortBy is TimedParameter &&
        (feed.sortBy as TimedParameter).isTimed &&
         feed.sortFrom == null) {
      feed.sortFrom = TimeSort.day;
    }

    return TransitionListing(
      listing: feed.listing,
      to: to,
      forceIfRefreshing: changedSort,
      onRemoveIds: (List<String> removedIds) {
        return UnstorePosts(postIds: removedIds);
      },
      onLoadPage: (Page page, Object transitionMarker) {
        return _GetFeedPosts(
          feed: feed,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser,
        );
      },
    );
  }
}

class _GetFeedPosts implements Effect {

  _GetFeedPosts({
    required this.feed,
    required this.page,
    required this.transitionMarker,
    this.user
  });

  final Feed feed;

  final Page page;

  final Object transitionMarker;

  final User? user;

  @override
  Future<Action> effect(CoreContext context) async {
    assert(feed.kind != FeedKind.home || user != null);
    try {
      ListingData<PostData> listing;
      if (feed.kind == FeedKind.home) {
        assert(feed.sortBy is HomeSort);
        assert(user != null);
        listing = await context.clientFromUser(user)
            .getHomePosts(page, feed.sortBy as HomeSort, feed.sortFrom);
      } else {
        assert(feed.sortBy is SubredditSort);
        final subredditName = feed.kind.name;
        listing = await context.clientFromUser(user)
            .getSubredditPosts(
              subredditName,
              page,
              feed.sortBy as SubredditSort,
              feed.sortFrom,
            );
      }

      return FinishListingTransition(
        listing: feed.listing,
        transitionMarker: transitionMarker,
        data: listing,
        onAddNewThings: (List<PostData> newThings) {
          return StorePosts(posts: newThings);
        },
      );
    } catch (_) {
      return ListingTransitionFailed(
        listing: feed.listing,
        transitionMarker: transitionMarker,
      );
    }
  }
}

extension FeedKindExtension on FeedKind {

  String get name {
    switch (this) {
      case FeedKind.home:
        return 'home';
      case FeedKind.popular:
        return 'popular';
      case FeedKind.all:
        return 'all';
    }
  }

  String get displayName {
    switch (this) {
      case FeedKind.home:
        return 'Home';
      case FeedKind.popular:
        return 'Popular';
      case FeedKind.all:
        return 'All';
    }
  }

  IconData get icon {
    switch (this) {
      case FeedKind.home:
        return Icons.home;
      case FeedKind.popular:
        return Icons.trending_up;
      case FeedKind.all:
        return Icons.all_inclusive;
    }
  }
}
