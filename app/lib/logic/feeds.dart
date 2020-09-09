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

class TransitionFeedPosts extends Action {

  TransitionFeedPosts({
    @required this.feed,
    @required this.to
  });

  final Feed feed;

  final ListingStatus to;

  @override
  dynamic update(AccountsOwner owner) {
    assert(feed.type != FeedType.home || owner.accounts.currentUser != null);
    return TransitionListing(
      listing: feed.posts,
      to: to,
      effectFactory: (Page page) {
        return GetFeedPosts(
          feed: feed,
          to: to,
          page: page,
          user: owner.accounts.currentUser);
      });
  }
}

class GetFeedPosts extends Effect {

  GetFeedPosts({
    @required this.feed,
    @required this.to,
    @required this.page,
    this.user
  });

  final Feed feed;

  final ListingStatus to;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) async {
    assert(feed.type != FeedType.home || user != null);
    final client = user != null ? context.reddit.asUser(user.token) : context.reddit.asDevice();
    ListingData<PostData> result;
    try {
      if (feed.type == FeedType.home) {
        assert(feed.sortBy is HomeSort);
        result = await client.getHomePosts(feed.sortBy, page);
      } else {
        assert(feed.sortBy is SubredditSort);
        final subredditName = feed.name;
        result = await client.getSubredditPosts(subredditName, feed.sortBy, page);
      }
    } catch (_) {
      return TransitionListingFailure();
    }

    return TransitionListingSuccess(
      listing: feed.posts,
      to: to,
      data: result,
      thingFactory: (PostData postData) => postData.toModel());
  }
}

extension FeedExtensions on Feed {

  String get name {
    switch (this.type) {
      case FeedType.home:
        return 'home';
      case FeedType.popular:
        return 'popular';
      case FeedType.all:
        return 'all';
    }
    throw ArgumentError('Invalid Feed.type value');
  }

  String get displayName {
    switch (this.type) {
      case FeedType.home:
        return 'Home';
      case FeedType.popular:
        return 'Popular';
      case FeedType.all:
        return 'All';
    }
    throw ArgumentError('Invalid Feed.type value');
  }
}

