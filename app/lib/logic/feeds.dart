import 'package:muex/muex.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/user.dart';

import 'listing.dart';
import 'post.dart';
import 'user.dart';

FeedPosts postsFromFeed(Feed feed) {
  Parameter sortBy;
  switch (feed) {
    case Feed.home:
      sortBy = HomeSort.best;
      break;
    case Feed.popular:
    case Feed.all:
      sortBy = SubredditSort.hot;
  }

  return FeedPosts(
    type: feed,
    sortBy: sortBy,
    listing: Listing(
      status: ListingStatus.idle));
}

extension FeedExtensions on Feed {

  String get _name {
    switch (this) {
      case Feed.home:
        return 'home';
      case Feed.popular:
        return 'popular';
      case Feed.all:
        return 'all';
    }
    throw ArgumentError('Invalid Feed.type value');
  }

  String get displayName {
    switch (this) {
      case Feed.home:
        return 'Home';
      case Feed.popular:
        return 'Popular';
      case Feed.all:
        return 'All';
    }
    throw ArgumentError('Invalid Feed.type value');
  }
}

class TransitionFeedPosts implements Update {

  TransitionFeedPosts({
    @required this.posts,
    @required this.to,
    this.sortBy,
    this.sortFrom
  });

  final FeedPosts posts;

  final ListingStatus to;

  final Parameter sortBy;

  final TimeSort sortFrom;

  @override
  Then update(AccountsOwner owner) {
    assert(posts.type != Feed.home || owner.accounts.currentUser != null);

    bool changedSort = false;
    if (sortBy != null && (sortBy != posts.sortBy || sortFrom != posts.sortFrom)) {
      // Since we're changing the sort value, we should be refreshing
      assert(to == ListingStatus.refreshing);
      posts..sortBy = sortBy
           ..sortFrom = sortFrom;
      changedSort = true;
    }

    return Then(TransitionListing(
      listing: posts.listing,
      to: to,
      forceIfRefreshing: changedSort,
      effectFactory: (Page page, Object transitionMarker) {
        return Then(GetFeedPosts(
          posts: posts,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser));
      }));
  }
}

class GetFeedPosts implements Effect {

  GetFeedPosts({
    @required this.posts,
    @required this.page,
    @required this.transitionMarker,
    this.user
  }) : assert(posts != null),
       assert(page != null),
       assert(transitionMarker != null);

  final FeedPosts posts;

  final Page page;

  final Object transitionMarker;

  final User user;

  @override
  Future<Then> effect(EffectContext context) async {
    assert(posts.type != Feed.home || user != null);
    try {
      ListingData<PostData> listing;
      if (posts.type == Feed.home) {
        assert(posts.sortBy is HomeSort);
        assert(user != null);
        listing = await context.clientFromUser(user).getHomePosts(page, posts.sortBy, posts.sortFrom);
      } else {
        assert(posts.sortBy is SubredditSort);
        final subredditName = posts.type._name;
        listing = await context.clientFromUser(user).getSubredditPosts(subredditName, page, posts.sortBy, posts.sortFrom);
      }

      final hasBeenViewed = await context.getPostListingDataHasBeenViewed(listing);

      return Then(FinishListingTransition(
        listing: posts.listing,
        transitionMarker: transitionMarker,
        data: listing,
        thingFactory: (PostData data) {
          return postFromData(data, hasBeenViewed: hasBeenViewed[data.id]);
        }));
    } catch (_) {
      return Then(ListingTransitionFailed(
        listing: posts.listing,
        transitionMarker: transitionMarker));
    }
  }
}

