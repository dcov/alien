import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/feeds.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../views/listing_scroll_view.dart';
import '../views/post_tiles.dart';
import '../widgets/routing.dart';
import '../widgets/tile.dart';
import '../widgets/widget_extensions.dart';

class FeedTile extends StatelessWidget {

  FeedTile({
    Key key,
    @required this.feed,
  }) : super(key: key);

  final Feed feed;

  void _pushPage(BuildContext context) {

    final posts = feed.toPosts();

    /// Push the feed posts page
    context.push(
        FeedPage.pageNameFrom(feed),
        (String pageName) => FeedPage(
          posts: posts,
          name: pageName));

    /// Dispatch a refresh event
    context.dispatch(
        TransitionFeedPosts(
          posts: posts,
          to: ListingStatus.refreshing));
  }

  IconData get _feedTypeIcon {
    switch (feed) {
      case Feed.home:
        return Icons.home;
      case Feed.popular:
        return Icons.trending_up;
      case Feed.all:
        return Icons.all_inclusive;
    }
    throw ArgumentError('Invalid Feed.type value');
  }

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () => _pushPage(context),
      icon: Icon(_feedTypeIcon),
      title: Text(
        feed.displayName,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}

class FeedPage extends EntryPage {

  FeedPage({
    @required this.posts,
    @required String name,
  }) : super(name: name);

  final FeedPosts posts;

  static String pageNameFrom(Feed feed) => feed.displayName;

  @override
  Route createRoute(_) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> _, Animation<double> __) {
        return _FeedPageView(
          posts: posts);
      });
  }
}

class _FeedPageView extends StatelessWidget {

  _FeedPageView({
    Key key,
    @required this.posts,
  }) : assert(posts != null),
       super(key: key);

  final FeedPosts posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close)),
                middle: Text(posts.type.displayName))))),
        Expanded(
          child: ListingScrollView(
            listing: posts.listing,
            onTransitionListing: (ListingStatus to) {
              context.dispatch(
                TransitionFeedPosts(
                  posts: posts,
                  to: to));
            },
            builder: (BuildContext context, Post post) {
              return PostTile(
                post: post,
                layout: PostTileLayout.list,
                includeSubredditName: true);
            }))
      ]);
  }
}

