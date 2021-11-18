import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/listing.dart';
import 'core/post.dart';
import 'core/subreddit.dart';
import 'core/subreddit_posts.dart';
import 'reddit/types.dart';
import 'widgets/page_router.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';

class SubredditPage extends PageEntry {

  SubredditPage({ required this.subreddit });

  final Subreddit subreddit;
  late final SubredditPosts _posts;

  @override
  void initState(BuildContext context) {
    _posts = postsFromSubreddit(subreddit);
    context.then(Then(TransitionSubredditPosts(
      posts: _posts,
      to: ListingStatus.refreshing,
      sortBy: SubredditSort.hot,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Expanded(child: ListingScrollView(
          listing: _posts.listing,
          onTransitionListing: (ListingStatus to) {
            context.then(Then(TransitionSubredditPosts(
              posts: _posts,
              to: to,
            )));
          },
          thingBuilder: (BuildContext _, Post post) {
            return PostTile(
              post: post,
              includeSubredditName: false,
            );
          },
        )),
        Material(
          elevation: 1.0,
          child: SizedBox(
            height: 56.0,
            child: NavigationToolbar(
              centerMiddle: false,
              leading: !isFirstPage ? PopPageButton() : null,
              middle: Text(
                subreddit.name,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ]
    );
  }
}
