import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/feed.dart';
import 'core/listing.dart';
import 'core/post.dart';
import 'reddit/types.dart';
import 'widgets/pressable.dart';
import 'widgets/routing.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_bottom_sheet.dart';

class _FeedContentBody extends StatelessWidget {

  _FeedContentBody({
    Key? key,
    required this.feed,
    required this.postPathPrefix,
  }) : super(key: key);

  final Feed feed;

  final String postPathPrefix;

  List<RedditArg> get _sortArgs {
    switch (feed.kind) {
      case FeedKind.home:
        return const <HomeSort>[
          HomeSort.best,
          HomeSort.hot,
          HomeSort.newest,
          HomeSort.controversial,
          HomeSort.top,
          HomeSort.rising
        ];
      case FeedKind.popular:
      case FeedKind.all:
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
      listing: feed.listing,
      onTransitionListing: (ListingStatus to) {
        context.then(
          Then(TransitionFeed(
            feed: feed,
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
                feed.kind.displayName,
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
                  currentSortBy: feed.sortBy,
                  currentSortFrom: feed.sortFrom,
                  onSort: (RedditArg sortBy, TimeSort? sortFrom) {
                    context.then(
                      Then(TransitionFeed(
                        feed: feed,
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

class FeedRoute extends RouteEntry {

  FeedRoute({
    required this.feed,
  });

  final Feed feed;

  static void goTo(BuildContext context, FeedKind kind, String pathPrefix) {
    context.goTo(
      '$pathPrefix${kind.name}',
      onCreateEntry: () {
        return FeedRoute(feed: feedFromKind(kind));
      },
      onUpdateEntry: (_) {
        // We don't have anything to update
      });
  }

  @override
  void initState(BuildContext context) {
    context.then(Then(
        TransitionFeed(
          feed: feed,
          to: ListingStatus.refreshing,)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
