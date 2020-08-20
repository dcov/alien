import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../models/subreddit.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;

class TransitionSubredditPosts extends Action {

  TransitionSubredditPosts({
    @required this.subreddit,
    @required this.posts,
    @required this.to
  });

  final Subreddit subreddit;

  final Listing<Post> posts;

  final ListingStatus to;

  @override
  dynamic update(_) {
    return TransitionListing(
      listing: posts,
      to: to,
      effectFactory: (Page page) => GetSubredditPosts(
        subreddit: subreddit,
        posts: posts,
        to: to,
        page: page));
  }
}

class GetSubredditPosts extends Effect {

  GetSubredditPosts({
    @required this.subreddit,
    @required this.posts,
    @required this.to,
    @required this.page
  });

  final Subreddit subreddit;

  final Listing<Post> posts;

  final ListingStatus to;

  final Page page;

  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asDevice()
      .getSubredditPosts(
        subreddit.name, SubredditSort.hot, page)
      .then(
        (ListingData<PostData> data) {
          return TransitionListingSuccess(
            listing: posts,
            to: to,
            data: data,
            thingFactory: (PostData data) {
              return data.toModel();
            });
        },
        onError: (_) {
          // TODO: error handling
        });
  }
}

