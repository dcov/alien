import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../models/subreddit.dart';
import '../models/user.dart';

import 'listing.dart';
import 'post.dart';
import 'user.dart';

SubredditPosts postsFromSubreddit(Subreddit subreddit) {
  return SubredditPosts(
    subreddit: subreddit,
    sortBy: SubredditSort.hot,
    listing: Listing<Post>(
      status: ListingStatus.idle,
      pagination: Pagination()));
}

class TransitionSubredditPosts implements Update {

  TransitionSubredditPosts({
    required this.posts,
    required this.to,
    this.sortBy,
    this.sortFrom
  });

  final SubredditPosts posts;

  final ListingStatus to;

  final SubredditSort? sortBy;

  final TimeSort? sortFrom;

  @override
  Then update(AccountsOwner owner) {
    bool changedSort = false;
    if (sortBy != null && (sortBy != posts.sortBy || sortFrom != posts.sortFrom)) {
      assert(to == ListingStatus.refreshing);
      posts..sortBy = sortBy!
           ..sortFrom = sortFrom
           /// We're changing the sort value so we'll clear the current posts since they no longer correspond to
           /// the sort value.
           ..listing.things.clear();
      changedSort = true;
    }

    return Then(TransitionListing(
      listing: posts.listing,
      to: to,
      forceIfRefreshing: changedSort,
      effectFactory: (Page page, Object transitionMarker) {
        return Then(_GetSubredditPosts(
          posts: posts,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser));
      }));
  }
}

class _GetSubredditPosts implements Effect {

  _GetSubredditPosts({
    required this.posts,
    required this.page,
    required this.transitionMarker,
    this.user,
  });

  final SubredditPosts posts;

  final Page page;

  final Object transitionMarker;

  final User? user;

  @override
  Future<Then> effect(EffectContext context) async {
    try {
      final listing = await context
          .clientFromUser(user)
          .getSubredditPosts(posts.subreddit.name, page, posts.sortBy, posts.sortFrom);

      /// We will use this when [FinishListingTransition] calls the [thingFactory].
      final hasBeenViewed = await context.getPostListingDataHasBeenViewed(listing);
      
      return Then(FinishListingTransition(
        listing: posts.listing,
        transitionMarker: transitionMarker,
        data: listing,
        thingFactory: (PostData data) {
          return postFromData(data, hasBeenViewed: hasBeenViewed[data.id]!);
        }));
    } catch (_) {
      return Then(ListingTransitionFailed(
        listing: posts.listing,
        transitionMarker: transitionMarker));
    }
  }
}
