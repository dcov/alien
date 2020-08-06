import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth.dart';
import '../models/home.dart';

import 'listing.dart';
import 'post.dart' show PostDataExtensions;

part 'home.msg.dart';

@action transitionHomePosts(AuthOwner owner, { @required Home home, @required ListingStatus to }) {
  final Auth auth = owner.auth;
  assert(auth.currentUser != null);

  return TransitionListing(
    listing: home.listing,
    to: to,
    effectFactory: (Page page) => GetHomePosts(
      home: home,
      to: to,
      page: page,
      user: auth.currentUser));
}

@effect getHomePosts(EffectContext context,
    { @required Home home, @required ListingStatus to, @required Page page, @required User user }) {

  return context.reddit
    .asUser(user.token)
    .getHomePosts(home.sortBy, page)
    .then(
      (ListingData<PostData> data) {
        return TransitionListingSuccess(
          listing: home.listing,
          to: to,
          data: data,
          thingFactory: (PostData data) => data.toModel());
      },
      onError: (_) {
        return TransitionListingFailure();
      });
}

