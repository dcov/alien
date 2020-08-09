import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../logic/home.dart';
import '../models/home.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../widgets/widget_extensions.dart';

import 'listing_scroll_view.dart';
import 'post_tiles.dart';

class HomeTile extends StatelessWidget {

  HomeTile({
    Key key,
    @required this.home,
  }) : super(key: key);

  final Home home;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(HomePage.createRoute(home)),
      leading: Icon(Icons.home),
      title: Text('Home'));
  }
}

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
        listing: home.listing,
        builder: (BuildContext _, Post post) {
          return PostTile(
            post: post,
            layout: PostTileLayout.list,
            includeSubredditName: true);
        },
        onUpdateListing: (ListingStatus to) {
          context.dispatch(TransitionHomePosts(
              home: home,
              to: to));
        }));
  }
}

