import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/accounts.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/user.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;
import 'user.dart';

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

  FeedPosts toPosts() {
    Object sortBy;
    switch (this) {
      case Feed.home:
        sortBy = HomeSort.best;
        break;
      case Feed.popular:
      case Feed.all:
        sortBy = SubredditSort.hot;
    }

    return FeedPosts(
      type: this,
      sortBy: sortBy,
      listing: Listing(
        status: ListingStatus.idle));
  }
}

class TransitionFeedPosts extends Action {

  TransitionFeedPosts({
    @required this.posts,
    @required this.to
  });

  final FeedPosts posts;

  final ListingStatus to;

  @override
  dynamic update(AccountsOwner owner) {
    assert(posts.type != Feed.home || owner.accounts.currentUser != null);
    return TransitionListing(
      listing: posts.listing,
      to: to,
      effectFactory: (Page page) {
        return GetFeedPosts(
          posts: posts,
          to: to,
          page: page,
          user: owner.accounts.currentUser);
      });
  }
}

class GetFeedPosts extends Effect {

  GetFeedPosts({
    @required this.posts,
    @required this.to,
    @required this.page,
    this.user
  });

  final FeedPosts posts;

  final ListingStatus to;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    assert(posts.type != Feed.home || user != null);
    ListingData<PostData> result;
    try {
      if (posts.type == Feed.home) {
        assert(posts.sortBy is HomeSort);
        assert(user != null);
        result = await context.clientFromUser(user).getHomePosts(posts.sortBy, page);
      } else {
        assert(posts.sortBy is SubredditSort);
        final subredditName = posts.type._name;
        result = await context.clientFromUser(user).getSubredditPosts(subredditName, posts.sortBy, page);
      }
    } catch (_) {
      return TransitionListingFailure();
    }

    return TransitionListingSuccess(
      listing: posts.listing,
      to: to,
      data: result,
      thingFactory: (PostData data) => data.toModel());
  }
}

