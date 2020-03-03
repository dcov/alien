import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../effects/effect_context.dart';
import '../listing/listing_model.dart' show ListingStatus;
import '../user/user_model.dart';

import 'home_events.dart';
import 'home_model.dart';

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
    return context.client
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

