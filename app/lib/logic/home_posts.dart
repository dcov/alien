import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/listing.dart';
import '../models/post.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;

part 'home_posts.msg.dart';

@action transitionHomePosts(
      AuthOwner owner, {
      @required Listing<Post> posts,
      @required ListingStatus to,
      HomeSort sortBy = HomeSort.best,
    }) {
  final Auth auth = owner.auth;
  assert(auth.currentUser != null);

  return TransitionListing(
    listing: posts,
    to: to,
    effectFactory: (Page page) => GetHomePosts(
      posts: posts,
      sortBy: sortBy,
      to: to,
      page: page,
      user: auth.currentUser));
}

@effect getHomePosts(
      EffectContext context, {
      @required Listing<Post> posts,
      @required HomeSort sortBy,
      @required ListingStatus to,
      @required Page page,
      @required User user
    }) {

  return context.reddit
    .asUser(user.token)
    .getHomePosts(sortBy, page)
    .then(
      (ListingData<PostData> data) {
        return TransitionListingSuccess(
          listing: posts,
          to: to,
          data: data,
          thingFactory: (PostData data) => data.toModel());
      },
      onError: (_) {
        return TransitionListingFailure();
      });
}

