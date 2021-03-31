import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show SubredditSort;

import '../logic/subreddit_posts.dart';
import '../logic/thing.dart';
import '../model/listing.dart' show ListingStatus;
import '../model/post.dart';
import '../model/subreddit.dart';
import '../ui/content_handle.dart';
import '../ui/pressable.dart';
import '../ui/theming.dart';

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

class SubredditRoute extends ShellRoute {

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

  @override
  RouteComponents build(BuildContext context) {
    final theming = Theming.of(context);
    final primaryColor = _determinePrimaryColor(theming, subreddit);
    return RouteComponents(
      titleDecoration: _buildTitleDecoration(theming, subreddit),
      titleMiddle: Text(
        subreddit.name,
        style: theming.headerText),
      contentHandle: ContentHandle(
        iconColor: primaryColor,
        items: <ContentHandleItem>[
          ContentHandleItem(
            icon: _determineSortIcon(_posts.sortBy),
            text: _posts.sortBy.name.toUpperCase(),
            onTap: () {
            })
        ]),
      contentBody: _ContentBody(
        key: ValueKey(path),
        posts: _posts,
        postPathPrefix: childPathPrefix),
      optionsHandle: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            PressableIcon(
              icon: Icons.sort,
              iconColor: theming.iconColor)
          ])),
      optionsBody: const SizedBox());
  }
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
    return ListingScrollView(
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
      });
  }
}
