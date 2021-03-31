import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show RedditArg, HomeSort,SubredditSort, TimeSort;

import '../logic/feeds.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../ui/listing_scroll_view.dart';
import '../ui/post_tile.dart';
import '../ui/pressable.dart';
import '../ui/sort_bottom_sheet.dart';

class FeedRoute extends ShellRoute {

  FeedRoute({
    required this.feed,
  });

  final Feed feed;

  late final FeedPosts _posts;

  static void goTo(BuildContext context, Feed feed, String pathPrefix) {
    context.goTo(
      '$pathPrefix${feed.name}',
      onCreateRoute: () {
        return FeedRoute(feed: feed);
      },
      onUpdateRoute: (_) {
        // We don't have anything to update
      });
  }

  @override
  void initState(BuildContext context) {
    _posts = postsFromFeed(feed);
    context.then(Then(
        TransitionFeedPosts(
          posts: _posts,
          to: ListingStatus.refreshing,)));
  }

  @override
  RouteComponents build(BuildContext context) {
    return RouteComponents(
      contentBody: _FeedContentBody(
        posts: _posts,
        postPathPrefix: childPathPrefix));
  }
}

class _FeedContentBody extends StatelessWidget {

  _FeedContentBody({
    Key? key,
    required this.posts,
    required this.postPathPrefix,
  }) : super(key: key);

  final FeedPosts posts;

  final String postPathPrefix;

  List<RedditArg> get _sortArgs {
    switch (posts.type) {
      case Feed.home:
        return const <HomeSort>[
          HomeSort.best,
          HomeSort.hot,
          HomeSort.newest,
          HomeSort.controversial,
          HomeSort.top,
          HomeSort.rising
        ];
      case Feed.popular:
      case Feed.all:
        return const <SubredditSort>[
          SubredditSort.hot,
          SubredditSort.newest,
          SubredditSort.controversial,
          SubredditSort.top,
          SubredditSort.rising
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListingScrollView(
      listing: posts.listing,
      onTransitionListing: (ListingStatus to) {
        context.then(
          Then(TransitionFeedPosts(
            posts: posts,
            to: to)));
      },
      thingBuilder: (BuildContext context, Post post) {
        return PostTile(
          post: post,
          pathPrefix: postPathPrefix,
          includeSubredditName: true);
      },
      scrollViewBuilder: (BuildContext context, ScrollController controller, Widget refreshSliver, Widget listSliver) {
        return CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverAppBar(
              toolbarHeight: 48.0,
              elevation: 1.0,
              pinned: true,
              backgroundColor: Theme.of(context).canvasColor,
              centerTitle: true,
              leading: PressableIcon(
                onPress: () => Navigator.pop(context),
                icon: Icons.arrow_back_ios,
                iconColor: Colors.black),
              title: Text(
                posts.type.displayName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
              actions: <Widget>[
                PressableIcon(
                  onPress: () { },
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  icon: Icons.more_vert,
                  iconColor: Colors.black)
              ]),
            refreshSliver,
            Connector(
              builder: (BuildContext context) {
                return SortSliver(
                  sortArgs: _sortArgs,
                  currentSortBy: posts.sortBy,
                  currentSortFrom: posts.sortFrom,
                  onSort: (RedditArg sortBy, TimeSort? sortFrom) {
                    context.then(
                      Then(TransitionFeedPosts(
                        posts: posts,
                        to: ListingStatus.refreshing,
                        sortBy: sortBy,
                        sortFrom: sortFrom)));
                  });
              }),
            listSliver
          ]);
      });
  }
}
