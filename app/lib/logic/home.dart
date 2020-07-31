import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../models/auth_model.dart';
import '../models/home_model.dart';

import 'listing_logic.dart';

class TransitionHomePosts implements Event {

  TransitionHomePosts({
    @required this.home,
    @required this.to,
  });

  final Home home;

  final ListingStatus to;

  @override
  Event update(RootAuth root) {
    final Auth auth = root.auth;
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
}

class GetHomePosts implements Effect {

  GetHomePosts({
    @required this.home,
    @required this.to,
    @required this.page,
    @required this.user,
  });

  final Home home;

  final ListingStatus to;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asUser(user.token)
      .getHomePosts(home.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return TransitionListingSuccess(
            listing: home.listing,
            to: to,
            data: data,
            thingFactory: (data) => Post.fromData(data));
        },
        onError: (_) {
          return TransitionListingFailure(
            listing: home.listing,
            to: to);
        });
  }
}

