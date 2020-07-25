import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/listing_model.dart';
import '../models/post_model.dart';
import '../models/subreddit_model.dart';

import 'listing_logic.dart';

class InitSubredditPosts implements Event {

  InitSubredditPosts({ @required this.subreddit })
    : assert(subreddit != null);

  final Subreddit subreddit;

  @override
  dynamic update(_) {
    subreddit.posts = Listing<Post>(
      status: ListingStatus.idle,
      things: <Post>[]);

    return TransitionSubredditPosts(
      subreddit: subreddit,
      to: ListingStatus.refreshing);
  }
}

class TransitionSubredditPosts implements Event {

  TransitionSubredditPosts({
    @required this.subreddit,
    @required this.to
  });

  final Subreddit subreddit;

  final ListingStatus to;

  @override
  dynamic update(_) {
    return TransitionListing(
      listing: subreddit.posts,
      to: to,
      effectFactory: (Page page) => GetSubredditPosts(
        subreddit: subreddit,
        to: to,
        page: page));
  }
}

class GetSubredditPosts implements Effect {

  const GetSubredditPosts({
    @required this.subreddit,
    @required this.to,
    @required this.page,
  });

  final Subreddit subreddit;

  final ListingStatus to;

  final Page page;
  
  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asDevice()
      .getSubredditPosts(
        subreddit.name, subreddit.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return TransitionListingSuccess(
            listing: subreddit.posts,
            to: to,
            data: data,
            thingFactory: (data) => Post.fromData(data));
        },
        onError: (_) {
          // TODO: error handling
        });
  }
}

