import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
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
      status: ListingStatus.idle));
}

class TransitionSubredditPosts extends Action {

  TransitionSubredditPosts({
    @required this.posts,
    @required this.to,
    this.sortBy,
    this.sortFrom
  }) : assert(posts != null),
       assert(to != null);

  final SubredditPosts posts;

  final ListingStatus to;

  final SubredditSort sortBy;

  final TimeSort sortFrom;

  @override
  dynamic update(AccountsOwner owner) {

    bool changedSort = false;
    if (sortBy != null && (sortBy != posts.sortBy || sortFrom != posts.sortFrom)) {
      assert(to == ListingStatus.refreshing);
      posts..sortBy = sortBy
           ..sortFrom = sortFrom
           /// We're changing the sort value so we'll clear the current posts since they no longer correspond to
           /// the sort value.
           ..listing.things.clear();
      changedSort = true;
    }

    return TransitionListing(
      listing: posts.listing,
      to: to,
      forceIfRefreshing: changedSort,
      effectFactory: (Page page, Object transitionMarker) => GetSubredditPosts(
        posts: posts,
        page: page,
        transitionMarker: transitionMarker,
        user: owner.accounts.currentUser));
  }
}

class GetSubredditPosts extends Effect {

  GetSubredditPosts({
    @required this.posts,
    @required this.page,
    @required this.transitionMarker,
    this.user,
  }) : assert(posts != null),
       assert(page != null),
       assert(transitionMarker != null);

  final SubredditPosts posts;

  final Page page;

  final Object transitionMarker;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getSubredditPosts(
        posts.subreddit.name, page, posts.sortBy, posts.sortFrom)
      .then(
        (ListingData<PostData> data) {
          return FinishListingTransition(
            listing: posts.listing,
            transitionMarker: transitionMarker,
            data: data,
            thingFactory: postFromData);
        },
        onError: (_) {
          return ListingTransitionFailed(
            listing: posts.listing,
            transitionMarker: transitionMarker);
        });
  }
}

