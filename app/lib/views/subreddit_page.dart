import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/subreddit_posts.dart';
import '../logic/thing.dart';
import '../models/listing.dart';
import '../models/subreddit.dart';
import '../models/post.dart';
import '../widgets/icons.dart';
import '../widgets/tile.dart';
import '../widgets/routing.dart';
import '../widgets/widget_extensions.dart';

import 'listing_scroll_view.dart';
import 'post_tiles.dart';

class _SubredditPageView extends StatelessWidget {

  _SubredditPageView({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final SubredditPosts posts;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Material(
            child: Padding(
              padding: EdgeInsets.only(top: context.mediaPadding.top),
              child: SizedBox(
                height: 48.0,
                child: NavigationToolbar(
                  leading: CloseButton(),
                  middle: Text(posts.subreddit.name))))),
          Expanded(
            child: ListingScrollView(
              listing: posts.listing,
              onTransitionListing: (ListingStatus to) {
                context.dispatch(
                  TransitionSubredditPosts(
                    posts: posts,
                    to: to));
              },
              builder: (BuildContext context, Post post) {
                return PostTile(
                  post: post,
                  layout: PostTileLayout.list,
                  includeSubredditName: false);
              }))
        ]));
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
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, _, __) {
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
  context.dispatch(
    TransitionSubredditPosts(
      posts: posts,
      to: ListingStatus.refreshing));
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

