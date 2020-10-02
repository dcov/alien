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
    @required this.to
  }) : assert(posts != null),
       assert(to != null);

  final SubredditPosts posts;

  final ListingStatus to;

  @override
  dynamic update(AccountsOwner owner) {
    return TransitionListing(
      listing: posts.listing,
      to: to,
      effectFactory: (Page page) => GetSubredditPosts(
        posts: posts,
        to: to,
        page: page,
        user: owner.accounts.currentUser));
  }
}

class GetSubredditPosts extends Effect {

  GetSubredditPosts({
    @required this.posts,
    @required this.to,
    @required this.page,
    this.user,
  }) : assert(posts != null),
       assert(to != null),
       assert(page != null);

  final SubredditPosts posts;

  final ListingStatus to;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.clientFromUser(user)
      .getSubredditPosts(
        posts.subreddit.name, posts.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return TransitionListingSuccess(
            listing: posts.listing,
            to: to,
            data: data,
            thingFactory: postFromData);
        },
        onError: (_) {
          // TODO: error handling
        });
  }
}

