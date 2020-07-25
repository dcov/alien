import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../models/auth_model.dart';
import '../models/home_model.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';

class UpdateHomePosts implements Event {

  UpdateHomePosts({
    @required this.home,
    @required this.newStatus,
  });

  final Home home;

  final ListingStatus newStatus;

  @override
  Effect update(RootAuth root) {
    final Auth auth = root.auth;
    assert(auth.currentUser != null);

    final Page page = updateListing(home.listing, newStatus);
    if (page != null) {
      return GetHomePosts(
        home: home,
        newStatus: newStatus,
        page: page,
        user: auth.currentUser);
    }
  }
}

class GetHomePostsSuccess extends UpdateListingSuccess {

  GetHomePostsSuccess({
    @required this.home,
    @required this.expectedStatus,
    @required this.result,
  });

  final Home home;

  final ListingStatus expectedStatus;

  final ListingData<PostData> result;

  @override
  dynamic update(_) {
    updateListingSuccess(
      home.listing,
      expectedStatus,
      result,
      (data) => Post.fromData(data));
  }
}

class GetHomePostsFail extends Event {

  GetHomePostsFail();

  @override
  dynamic update(_) {
    // TODO: Implement
  }
}

class GetHomePosts extends Effect {

  GetHomePosts({
    @required this.home,
    @required this.newStatus,
    @required this.page,
    @required this.user,
  });

  final Home home;

  final ListingStatus newStatus;

  final Page page;

  final User user;

  @override
  dynamic perform(EffectContext context) {
    return context.reddit
      .asUser(user.token)
      .getHomePosts(home.sortBy, page)
      .then(
        (ListingData<PostData> data) {
          return GetHomePostsSuccess(
            home: home,
            expectedStatus: newStatus,
            result: data);
        },
        onError: (_) {
          return GetHomePostsFail();
        });
  }
}

