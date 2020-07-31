import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../models/subreddit.dart';

import 'listing.dart';

part 'subreddit_posts.g.dart';

@event transitionSubredditPosts(_,
    { @required Subreddit subreddit, @required ListingStatus to }) {

  return TransitionListing(
    listing: subreddit.posts,
    to: to,
    effectFactory: (Page page) => GetSubredditPosts(
      subreddit: subreddit,
      to: to,
      page: page));
}

@effect getSubredditPosts(EffectContext context,
    { @required Subreddit subreddit, @required ListingStatus to, @required Page page }) {

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

