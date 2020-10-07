import 'package:elmer/elmer.dart';
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

class TransitionFeedPosts extends Action {

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
  dynamic update(AccountsOwner owner) {
    assert(posts.type != Feed.home || owner.accounts.currentUser != null);

    bool changedSort = false;
    if (sortBy != null && (sortBy != posts.sortBy || sortFrom != posts.sortFrom)) {
      // Since we're changing the sort value, we should be refreshing
      assert(to == ListingStatus.refreshing);
      posts..sortBy = sortBy
           ..sortFrom = sortFrom;
      changedSort = true;
    }

    return TransitionListing(
      listing: posts.listing,
      to: to,
      forceIfRefreshing: changedSort,
      effectFactory: (Page page, Object transitionMarker) {
        return GetFeedPosts(
          posts: posts,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser);
      });
  }
}

class GetFeedPosts extends Effect {

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
  dynamic perform(EffectContext context) async {
    assert(posts.type != Feed.home || user != null);
    ListingData<PostData> data;
    try {
      if (posts.type == Feed.home) {
        assert(posts.sortBy is HomeSort);
        assert(user != null);
        data = await context.clientFromUser(user).getHomePosts(page, posts.sortBy, posts.sortFrom);
      } else {
        assert(posts.sortBy is SubredditSort);
        final subredditName = posts.type._name;
        data = await context.clientFromUser(user).getSubredditPosts(subredditName, page, posts.sortBy, posts.sortFrom);
      }
    } catch (_) {
      return ListingTransitionFailed(
        listing: posts.listing,
        transitionMarker: transitionMarker);
    }

    return FinishListingTransition(
      listing: posts.listing,
      transitionMarker: transitionMarker,
      data: data,
      thingFactory: postFromData);
  }
}

