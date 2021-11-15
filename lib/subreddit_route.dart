import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/listing.dart';
import 'core/post.dart';
import 'core/subreddit.dart';
import 'core/subreddit_posts.dart';
import 'core/thing.dart';
import 'reddit/types.dart';
import 'widgets/basic.dart';
import 'widgets/pressable.dart';
import 'widgets/routing.dart';
import 'widgets/theming.dart';
import 'widgets/toolbar.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';

IconData _determineSortIcon(SubredditSort sortBy) {
    switch (sortBy) {
      case SubredditSort.hot:
        return Icons.whatshot;
      case SubredditSort.newest:
        return Icons.fiber_new;
      case SubredditSort.top:
        return Icons.bar_chart;
      case SubredditSort.controversial:
        return Icons.face;
      case SubredditSort.rising:
        return Icons.trending_up;
    }
    return Icons.sort;
}

Color _determinePrimaryColor(ThemingData theming, Subreddit subreddit) {
  if (subreddit.primaryColor != null)
    return Color(subreddit.primaryColor!);
  return theming.altCanvasColor;
}

BoxDecoration _buildTitleDecoration(
    ThemingData theming,
    Subreddit subreddit
  ) {
  Color color;
  if (subreddit.bannerBackgroundColor != null) {
    color = Color(subreddit.bannerBackgroundColor!);
  } else {
    color = theming.canvasColor;
  }

  DecorationImage? image;
  if (subreddit.bannerImageUrl != null) {
    image = DecorationImage(
      image: CachedNetworkImageProvider(
        subreddit.bannerImageUrl!,
      ),
      fit: BoxFit.cover,
    );
  }
  return BoxDecoration(
    color: color,
    image: image,
  );
}

class _SubredditRouteView extends StatelessWidget {

  _SubredditRouteView({
    Key? key,
    required this.subreddit,
    required this.posts,
    required this.postRoutePathPrefix
  }) : super(key: key);

  final Subreddit subreddit;

  final SubredditPosts posts;

  final String postRoutePathPrefix;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Material(
      color: theming.canvasColor,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Toolbar(
                leading: BackArrow(),
                middle: Text(
                  subreddit.name,
                  style: theming.headerText)),
              Expanded(
                child: ListingScrollView(
                  listing: posts.listing,
                  onTransitionListing: (ListingStatus to) {
                    context.then(Then(TransitionSubredditPosts(posts: posts, to: to)));
                  },
                  thingBuilder: (BuildContext context, Post post) {
                    return PostTile(
                      post: post,
                      includeSubredditName: false);
                  })),
            ]),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.black54.withOpacity(0.8),
              child: SizedBox(
                height: 48.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PressableIcon(
                      icon: Icons.sort,
                      iconColor: theming.iconColor)
                  ])))),
        ]));
  }
}

class SubredditRoute extends RouteEntry {

  SubredditRoute({
    required this.subreddit
  });

  final Subreddit subreddit;

  late final SubredditPosts _posts;

  static String pathFrom(Subreddit subreddit, String pathPrefix) {
    return '$pathPrefix${subreddit.fullId}';
  }

  static void goTo(BuildContext context, Subreddit subreddit, String path) {
    context.goTo(
      path,
      onCreateEntry: () {
        return SubredditRoute(subreddit: subreddit);
      },
      onUpdateEntry: (RouteEntry entry) {
        assert(entry is SubredditRoute);
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

  @override
  Widget build(BuildContext context) {
    return _SubredditRouteView(
      subreddit: subreddit,
      posts: _posts,
      postRoutePathPrefix: this.childPathPrefix);
  }
}
