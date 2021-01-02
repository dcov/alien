import 'package:flutter/material.dart';
import 'package:mal_flutter/mal_flutter.dart';
import 'package:reddit/reddit.dart';

import '../logic/subreddit_posts.dart';
import '../logic/thing.dart';
import '../models/listing.dart';
import '../models/subreddit.dart';
import '../models/post.dart';
import '../widgets/draggable_page_route.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import '../widgets/tile.dart';
import '../widgets/routing.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_bottom_sheet.dart';

class _SubredditPageView extends StatelessWidget {

  _SubredditPageView({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final SubredditPosts posts;

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
            includeSubredditName: false);
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
                  icon: Icons.arrow_back_ios_rounded,
                  iconColor: Colors.black),
                title: Text(
                  posts.subreddit.name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
                actions: <Widget>[
                  PressableIcon(
                    onPress: () { },
                    icon: Icons.more_vert,
                    iconColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16.0))
                ]),
              refreshSliver,
              Connector(
                builder: (BuildContext context) {
                  return SortSliver(
                    parameters: [
                      SubredditSort.hot,
                      SubredditSort.newest,
                      SubredditSort.controversial,
                      SubredditSort.top,
                      SubredditSort.rising
                    ],
                    currentSortBy: posts.sortBy,
                    currentSortFrom: posts.sortFrom,
                    onSort: (SubredditSort sortBy, TimeSort sortFrom) {
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

class _SubredditPage extends EntryPage {

  _SubredditPage({
    @required this.posts,
    @required String name,
  }) : super(name: name);

  final SubredditPosts posts;

  @override
  Route createRoute(BuildContext context) {
    return DraggablePageRoute(
      settings: this,
      builder: (BuildContext context) {
        return _SubredditPageView(posts: posts);
      });
  }
}

String subredditPageNameFrom(Subreddit subreddit, [String prefix = '']) {
  assert(prefix != null);
  return prefix + subreddit.fullId;
}

void _showSubredditPage({
    @required BuildContext context,
    @required Subreddit subreddit,
    String pageNamePrefix = ''
  }) {
  assert(context != null);
  assert(subreddit != null);
  assert(pageNamePrefix != null);

    /// Create the posts model
  final posts = postsFromSubreddit(subreddit);

  /// Push the subreddit page
  context.push(
    subredditPageNameFrom(subreddit, pageNamePrefix),
    (String pageName) {
      return _SubredditPage(
        posts: posts,
        name: pageName);
    });

  /// Dispatch a posts refresh event
  context.then(
    Then(TransitionSubredditPosts(
      posts: posts,
      to: ListingStatus.refreshing)));
}


class SubredditTile extends StatelessWidget {

  SubredditTile({
    Key key,
    @required this.subreddit,
    this.pageNamePrefix = ''
  }) : assert(subreddit != null),
       assert(pageNamePrefix != null),
       super(key: key);

  final Subreddit subreddit;

  final String pageNamePrefix;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return CustomTile(
        onTap: () => _showSubredditPage(
          context: context,
          subreddit: subreddit,
          pageNamePrefix: pageNamePrefix),
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
