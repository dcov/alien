import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../logic/feeds.dart';
import '../models/feed.dart';
import '../models/listing.dart';
import '../models/post.dart';
import '../widgets/routing.dart';
import '../widgets/tile.dart';
import '../widgets/widget_extensions.dart';

import 'listing_scroll_view.dart';
import 'post_page.dart';

class _FeedPageView extends StatelessWidget {

  _FeedPageView({
    Key key,
    @required this.posts,
  }) : assert(posts != null),
       super(key: key);

  final FeedPosts posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close)),
                middle: Text(
                  posts.type.displayName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500)))))),
        Expanded(
          child: ListingScrollView(
            listing: posts.listing,
            onTransitionListing: (ListingStatus to) {
              context.dispatch(
                TransitionFeedPosts(
                  posts: posts,
                  to: to));
            },
            builder: (BuildContext context, Post post) {
              return PostTile(
                post: post,
                includeSubredditName: true);
            }))
      ]);
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
    return MaterialPageRoute(
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

