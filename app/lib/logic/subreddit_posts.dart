import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../models/subreddit.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;

extension SubredditToPostsExtension on Subreddit {

  SubredditPosts toPosts() {
    return SubredditPosts(
      subreddit: this,
      sortBy: SubredditSort.hot,
      listing: Listing<Post>(
        status: ListingStatus.idle));
  }
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
  dynamic update(_) {
    return TransitionListing(
      listing: posts.listing,
      to: to,
      effectFactory: (Page page) => GetSubredditPosts(
        posts: posts,
        to: to,
        page: page));
  }
}

class GetSubredditPosts extends Effect {

  GetSubredditPosts({
    @required this.posts,
    @required this.to,
    @required this.page
  }) : assert(posts != null),
       assert(to != null),
       assert(page != null);


  final SubredditPosts posts;

  final ListingStatus to;

  final Page page;

  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asDevice()
      .getSubredditPosts(
        posts.subreddit.name, posts.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return TransitionListingSuccess(
            listing: posts.listing,
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

