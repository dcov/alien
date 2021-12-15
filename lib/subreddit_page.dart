import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/listing.dart';
import 'core/subreddit.dart';
import 'core/subreddit_posts.dart';
import 'core/thing_store.dart';
import 'reddit/types.dart';
import 'widgets/constants.dart';
import 'widgets/page_stack.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';

class SubredditPage extends PageStackEntry {

  SubredditPage({
    required ValueKey<String> key,
    required this.subreddit,
  }) : super(key: key);

  final Subreddit subreddit;
  late final SubredditPosts _posts;

  @override
  void initState(BuildContext context) {
    _posts = SubredditPosts(subredditName: subreddit.name);
    context.then(TransitionSubredditPosts(
      posts: _posts,
      to: ListingStatus.refreshing,
      sortBy: SubredditSort.hot,
    ));
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration bannerDecoration;
    if (subreddit.bannerImageUrl != null) {
      bannerDecoration = BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(subreddit.bannerImageUrl!),
          fit: BoxFit.fill,
        ),
      );
    } else if (subreddit.bannerBackgroundColor != null) {
      bannerDecoration = BoxDecoration(
        color: Color(subreddit.bannerBackgroundColor!),
      );
    } else {
      bannerDecoration = const BoxDecoration();
    }

    return Stack(
      key: ValueKey(subreddit.id),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: kTotalAppBarHeight),
          child: ListingScrollView(
            listing: _posts.listing,
            onTransitionListing: (ListingStatus to) {
              context.then(TransitionSubredditPosts(
                posts: _posts,
                to: to,
              ));
            },
            thingBuilder: (BuildContext context, String id) {
              return PostTile(
                post: (context.state as ThingStoreOwner).store.idToPost(id),
                includeSubredditName: false,
              );
            },
          ),
        ),
        DecoratedBox(
          decoration: bannerDecoration,
          position: DecorationPosition.foreground,
          child: SizedBox(
            width: double.infinity,
            height: kTotalAppBarHeight,
          ),
        ),
        PopPageButton(),
      ],
    );
  }
}
