import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart' show Page, ListingData, PostData;

import '../auth/auth_model.dart';
import '../listing/listing_model.dart' show ListingStatus;
import '../listing/listing_events.dart';
import '../post/post_model.dart';

import 'home_effects.dart';
import 'home_model.dart';

class UpdateHomePosts extends UpdateListing {

  UpdateHomePosts({
    @required this.home,
    @required this.newStatus,
  });

  final Home home;

  final ListingStatus newStatus;

  @override
  dynamic update(RootAuth root) {
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

