import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex/muex.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show SubredditSort, TimeSort;

import '../logic/subreddit_posts.dart';
import '../logic/thing.dart';
import '../models/listing.dart' show ListingStatus;
import '../models/post.dart';
import '../models/subreddit.dart';
import '../widgets/content_handle.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_bottom_sheet.dart';

class SubredditRoute extends ShellRoute {

  SubredditRoute({
    required this.subreddit
  });

  final Subreddit subreddit;

  late final SubredditPosts _posts;

  late Connection _connection;

  static void goTo(BuildContext context, Subreddit subreddit, String pathPrefix) {
    context.goTo(
      '$pathPrefix${subreddit.fullId}',
      onCreateRoute: () {
        return SubredditRoute(subreddit: subreddit);
      },
      onUpdateRoute: (ShellRoute route) {
        assert(route is SubredditRoute);
        // TODO
      });
  }

  @override
  void initState(BuildContext context) {
    _posts = postsFromSubreddit(subreddit);
    context.then(
      Then(TransitionSubredditPosts(
        posts: _posts,
        to: ListingStatus.refreshing,
        sortBy: SubredditSort.hot)));
  }

  ContentHandleItem _buildSortItem() {
    late IconData icon;
    late Color color;
    switch (_posts.sortBy) {
      case SubredditSort.hot:
        icon = Icons.whatshot;
        color = Colors.red;
        break;
      case SubredditSort.newest:
        icon = Icons.new_releases;
        color = Colors.blue;
        break;
      case SubredditSort.top:
        icon = Icons.bar_chart;
        color = Colors.amber.shade300;
        break;
      case SubredditSort.controversial:
        icon = Icons.face;
        color = Colors.grey;
        break;
      case SubredditSort.rising:
        icon = Icons.trending_up;
        color = Colors.red.shade100;
    }
    return ContentHandleItem(
      icon: icon,
      color: color,
      text: _posts.sortBy.name.toUpperCase(),
      onTap: () {
      });
  }

  @override
  RouteComponents build(BuildContext context) {
    return RouteComponents(
      titleDecoration: _buildTitleDecoration(context, subreddit),
      titleMiddle: Text(
        subreddit.name,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)),
      contentHandle: ContentHandle(
        items: <ContentHandleItem>[
          _buildSortItem()
        ]),
      contentBody: _ContentBody(
        key: ValueKey(path),
        posts: _posts,
        postPathPrefix: childPathPrefix),
      optionsHandle: Stack(
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 0.0,
                    color: Colors.grey))),
              child: SizedBox.expand())),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                PressableIcon(
                  icon: Icons.sort,
                  iconColor: Colors.grey)
              ])),
        ]),
      optionsBody: Material());
  }
}

BoxDecoration _buildTitleDecoration(
    BuildContext context,
    Subreddit subreddit
  ) {
  Color color;
  if (subreddit.bannerBackgroundColor != null) {
    color = Color(subreddit.bannerBackgroundColor!);
  } else {
    color = Theme.of(context).canvasColor;
  }

  DecorationImage? image;
  if (subreddit.bannerImageUrl != null) {
    image = DecorationImage(
      image: CachedNetworkImageProvider(
        subreddit.bannerImageUrl),
      fit: BoxFit.cover);
  }
  return BoxDecoration(
    color: color,
    image: image);
}

class _ContentBody extends StatelessWidget {

  _ContentBody({
    Key? key,
    required this.posts,
    required this.postPathPrefix,
  }) : super(key: key);

  final SubredditPosts posts;

  final String postPathPrefix;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListingScrollView(
        listing: posts.listing,
        onTransitionListing: (ListingStatus to) {
          context.then(
            Then(TransitionSubredditPosts(
              posts: posts,
              to: to)));
        },
        thingBuilder: (BuildContext context, Post post) {
          return PostTile(
            post: post,
            pathPrefix: postPathPrefix,
            includeSubredditName: false);
        },
        scrollViewBuilder: (BuildContext context, ScrollController controller, Widget refreshSliver, Widget listSliver) {
          return CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              refreshSliver,
              Connector(
                builder: (BuildContext context) {
                  return SortSliver(
                    sortArgs: const <SubredditSort>[
                      SubredditSort.hot,
                      SubredditSort.newest,
                      SubredditSort.controversial,
                      SubredditSort.top,
                      SubredditSort.rising
                    ],
                    currentSortBy: posts.sortBy,
                    currentSortFrom: posts.sortFrom,
                    onSort: (SubredditSort sortBy, TimeSort? sortFrom) {
                      context.then(
                        Then(TransitionSubredditPosts(
                          posts: posts,
                          to: ListingStatus.refreshing,
                          sortBy: sortBy,
                          sortFrom: sortFrom)));
                    });
                }),
              listSliver
            ]);
        }));
  }
}
