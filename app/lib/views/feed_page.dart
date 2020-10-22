import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../logic/feeds.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../widgets/draggable_page_route.dart';
import '../widgets/pressable.dart';
import '../widgets/routing.dart';
import '../widgets/tile.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_bottom_sheet.dart';

class _FeedPageView extends StatelessWidget {

  _FeedPageView({
    Key key,
    @required this.posts,
  }) : assert(posts != null),
       super(key: key);

  final FeedPosts posts;

  List<Parameter> get _sortParameters {
    switch (posts.type) {
      case Feed.home:
        return <HomeSort>[
          HomeSort.best,
          HomeSort.hot,
          HomeSort.newest,
          HomeSort.controversial,
          HomeSort.top,
          HomeSort.rising
        ];
      case Feed.popular:
      case Feed.all:
        return <SubredditSort>[
          SubredditSort.hot,
          SubredditSort.newest,
          SubredditSort.controversial,
          SubredditSort.top,
          SubredditSort.rising
        ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListingScrollView(
        listing: posts.listing,
        onTransitionListing: (ListingStatus to) {
          context.dispatch(
            TransitionFeedPosts(
              posts: posts,
              to: to));
        },
        thingBuilder: (BuildContext context, Post post) {
          return PostTile(
            post: post,
            includeSubredditName: true);
        },
        scrollViewBuilder: (BuildContext context, ScrollController controller, Widget refreshSliver, Widget listSliver) {
          return CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              SliverAppBar(
                elevation: 1.0,
                pinned: true,
                backgroundColor: Theme.of(context).canvasColor,
                leading: PressableIcon(
                  onPress: () => Navigator.pop(context),
                  icon: Icons.close,
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
                    parameters: _sortParameters,
                    currentSortBy: posts.sortBy,
                    currentSortFrom: posts.sortFrom,
                    onSort: (Parameter parameter, TimeSort sortFrom) {
                      context.dispatch(
                        TransitionFeedPosts(
                          posts: posts,
                          to: ListingStatus.refreshing,
                          sortBy: parameter,
                          sortFrom: sortFrom));
                    });
                }),
              listSliver
            ]);
        }));
  }
}

class _FeedPage extends EntryPage {

  _FeedPage({
    @required this.posts,
    @required String name,
  }) : super(name: name);

  final FeedPosts posts;

  @override
  Route createRoute(_) {
    return DraggablePageRoute(
      settings: this,
      builder: (_) {
        return _FeedPageView(
          posts: posts);
      });
  }
}

String feedPageNameFrom(Feed feed) => feed.displayName;

void _showFeedPage({
    @required BuildContext context,
    @required Feed feed
  }) {
  assert(context != null);
  assert(feed != null);
  /// Create the FeedPosts model
  final posts = postsFromFeed(feed);

  /// Push the feed posts page
  context.push(
      feedPageNameFrom(feed),
      (String pageName) => _FeedPage(
        posts: posts,
        name: pageName));

  /// Dispatch a refresh event
  context.dispatch(
      TransitionFeedPosts(
        posts: posts,
        to: ListingStatus.refreshing));
}

class FeedTile extends StatelessWidget {

  FeedTile({
    Key key,
    @required this.feed,
  }) : super(key: key);

  final Feed feed;

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
      onTap: () => _showFeedPage(
        context: context,
        feed: feed),
      icon: Icon(_feedTypeIcon),
      title: Text(
        feed.displayName,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}

