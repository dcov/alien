import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show SubredditSort, TimeSort;

import '../logic/subreddit_posts.dart';
import '../logic/thing.dart';
import '../models/listing.dart' show ListingStatus;
import '../models/post.dart';
import '../models/subreddit.dart';
import '../widgets/content_handle.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';
import '../widgets/tile.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_bottom_sheet.dart';

String _subredditRoutePathFrom(String prefix, Subreddit subreddit) {
  return '$prefix${subreddit.fullId}';
}

void goToSubredditRoute(BuildContext context, String routePath, Subreddit subreddit) {
  context.goTo(
    routePath,
    onCreateRoute: () {
      return SubredditRoute(subreddit: subreddit);
    },
    onUpdateRoute: (ShellRoute route) {
      assert(route is SubredditRoute);

    });
}

class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key? key,
    required this.subreddit,
    required this.pathPrefix
  }) : super(key: key);

  final Subreddit subreddit;

  final String pathPrefix;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return CustomTile(
        onTap: () {
          goToSubredditRoute(
            context,
            _subredditRoutePathFrom(pathPrefix, subreddit),
            subreddit);
        },
        icon: Icon(
          CustomIcons.subreddit,
          color: Colors.blueGrey),
        title: Text(
          subreddit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500)));
    });
}

class SubredditRoute extends ShellRoute {

  SubredditRoute({
    required this.subreddit
  });

  final Subreddit subreddit;

  late final SubredditPosts _posts;

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
      titleDecoration: BoxDecoration(
        color: Colors.grey),
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
