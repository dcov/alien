import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../models/user.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;

class TransitionHomePosts extends Action {

  TransitionHomePosts({
    @required this.posts,
    @required this.to,
    this.sortBy = HomeSort.best
  });

  final Listing<Post> posts;

  final ListingStatus to;

  final HomeSort sortBy;

  @override
  dynamic update(AuthOwner owner) {
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
}

class GetHomePosts extends Effect {

  GetHomePosts({
    @required this.posts,
    @required this.sortBy,
    @required this.to,
    @required this.page,
    @required this.user
  });
  
  final Listing<Post> posts;

  final HomeSort sortBy;

  final ListingStatus to;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) {
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
}

