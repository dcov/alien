import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';
import '../reddit/utils.dart';

import 'context.dart';
import 'accounts.dart';
import 'listing.dart';
import 'post.dart';
import 'user.dart';

part 'feed.g.dart';

enum FeedKind {
  home,
  popular,
  all
}

abstract class Feed implements Model {

  factory Feed({
    required FeedKind kind,
    required RedditArg sortBy,
    TimeSort? sortFrom,
    required Listing<Post> listing,
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

  Listing<Post> get listing;
}

Feed feedFromKind(FeedKind kind) {
  RedditArg sortBy;
  switch (kind) {
    case FeedKind.home:
      sortBy = HomeSort.best;
      break;
    case FeedKind.popular:
    case FeedKind.all:
      sortBy = SubredditSort.hot;
  }

  return Feed(
    kind: kind,
    sortBy: sortBy,
    listing: Listing(
      status: ListingStatus.idle,
      pagination: Pagination()));
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
  Then update(AccountsOwner owner) {
    assert(feed.kind != FeedKind.home || owner.accounts.currentUser != null,
        'Tried to load the home feed without a signed in user');

    bool changedSort = false;
    if (sortBy != null && (sortBy != feed.sortBy || sortFrom != feed.sortFrom)) {
      // Since we're changing the sort value, we should be refreshing
      assert(to == ListingStatus.refreshing);
      feed..sortBy = sortBy!
           ..sortFrom = sortFrom;
      changedSort = true;
    }

    return Then(TransitionListing(
      listing: feed.listing,
      to: to,
      forceIfRefreshing: changedSort,
      effectFactory: (Page page, Object transitionMarker) {
        return Then(_GetFeedPosts(
          feed: feed,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser));
      }));
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
  Future<Then> effect(CoreContext context) async {
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
            .getSubredditPosts(subredditName, page, feed.sortBy as SubredditSort, feed.sortFrom);
      }

      final hasBeenViewed = await context.getPostListingDataHasBeenViewed(listing);

      return Then(FinishListingTransition(
        listing: feed.listing,
        transitionMarker: transitionMarker,
        data: listing,
        thingFactory: (PostData data) {
          return postFromData(data, hasBeenViewed: hasBeenViewed[data.id]!);
        }));
    } catch (_) {
      return Then(ListingTransitionFailed(
        listing: feed.listing,
        transitionMarker: transitionMarker));
    }
  }
}
