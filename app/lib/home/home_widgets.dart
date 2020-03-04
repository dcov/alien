import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../listing/listing_model.dart' show ListingStatus;
import '../listing/listing_widgets.dart';
import '../post/post_model.dart';
import '../post/post_widgets.dart';

import 'home_events.dart';
import 'home_model.dart';

class HomePage extends StatelessWidget {

  HomePage({
    Key key,
    @required this.home
  }) : super(key: key);

  final Home home;

  static Route createRoute(Home home) {
    return CupertinoPageRoute(
      title: "Home",
      builder: (_) => HomePage(home: home));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: ListingScrollView(
        listing: home.posts,
        builder: (BuildContext _, Post post) {
          return PostTile(
            post: post,
            layout: PostTileLayout.list,
            includeSubredditName: true);
        },
        onUpdateListing: (ListingStatus newStatus) {
          context.dispatch(UpdateHomePosts(
              home: home,
              newStatus: newStatus));
        }));
  }
}

