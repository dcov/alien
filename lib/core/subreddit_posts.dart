import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'context.dart';
import 'accounts.dart';
import 'listing.dart';
import 'thing_store.dart';
import 'user.dart';

part 'subreddit_posts.g.dart';

abstract class SubredditPosts implements Model {

  factory SubredditPosts({
    required String subredditName,
  }) {
    return _$SubredditPosts(
      subredditName: subredditName,
      sortBy: SubredditSort.hot,
      listing: Listing(),
    );
  }

  factory SubredditPosts.raw({
    required String subredditName,
    required SubredditSort sortBy,
    TimeSort sortFrom,
    required Listing listing
  }) = _$SubredditPosts;

  String get subredditName;

  SubredditSort get sortBy;
  set sortBy(SubredditSort value);

  TimeSort? get sortFrom;
  set sortFrom(TimeSort? value);

  Listing get listing;
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
  Action update(AccountsOwner owner) {
    bool changedSort = false;
    if (sortBy != null && (sortBy != posts.sortBy || sortFrom != posts.sortFrom)) {
      assert(to == ListingStatus.refreshing);
      posts..sortBy = sortBy!
           ..sortFrom = sortFrom;
      changedSort = true;
    }

    return TransitionListing(
      listing: posts.listing,
      to: to,
      forceIfRefreshing: changedSort,
      onRemoveIds: (List<String> removedIds) {
        return UnstorePosts(postIds: removedIds);
      },
      onLoadPage: (Page page, Object transitionMarker) {
        return _GetSubredditPosts(
          posts: posts,
          page: page,
          transitionMarker: transitionMarker,
          user: owner.accounts.currentUser,
        );
      },
    );
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
  Future<Action> effect(CoreContext context) async {
    try {
      final listing = await context
          .clientFromUser(user)
          .getSubredditPosts(posts.subredditName, page, posts.sortBy, posts.sortFrom);

      return FinishListingTransition(
        listing: posts.listing,
        transitionMarker: transitionMarker,
        data: listing,
        onAddNewThings: (List<PostData> posts) {
          return StorePosts(posts: posts);
        },
      );
    } catch (_) {
      return ListingTransitionFailed(
        listing: posts.listing,
        transitionMarker: transitionMarker,
      );
    }
  }
}
