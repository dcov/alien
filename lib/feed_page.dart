import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/feed.dart';
import 'core/listing.dart';
import 'core/post.dart';
import 'reddit/types.dart';
import 'widgets/page_router.dart';

import 'listing_scroll_view.dart';
import 'post_tile.dart';
import 'sort_views.dart';

class FeedPage extends PageEntry {

  factory FeedPage({
    required FeedKind kind,
  }) {
    final feed = feedFromKind(kind);
    return FeedPage._(feed);
  }

  FeedPage._(this.feed) : super(key: ValueKey(feed));

  final Feed feed;

  List<RedditArg> get _sortArgs {
    switch (feed.kind) {
      case FeedKind.home:
        return const <HomeSort>[
          HomeSort.best,
          HomeSort.hot,
          HomeSort.newest,
          HomeSort.controversial,
          HomeSort.top,
          HomeSort.rising
        ];
      case FeedKind.popular:
      case FeedKind.all:
        return const <SubredditSort>[
          SubredditSort.hot,
          SubredditSort.newest,
          SubredditSort.controversial,
          SubredditSort.top,
          SubredditSort.rising
        ];
    }
  }

  @override
  void initState(BuildContext context) {
    context.then(Then(TransitionFeed(
      feed: feed,
      to: ListingStatus.refreshing,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Material(
        elevation: 2.0,
        child: SizedBox(
          height: 56.0,
          child: NavigationToolbar(
            centerMiddle: false,
            leading: !isFirstPage ? CloseButton() : null,
            middle: Text(
              feed.kind.displayName,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Connector(
              builder: (BuildContext context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SortButton(
                      onSortChanged: (RedditArg newSortBy) {
                        context.then(Then(TransitionFeed(
                          feed: feed,
                          to: ListingStatus.refreshing,
                          sortBy: newSortBy,
                        )));
                      },
                      sortArgs: _sortArgs,
                      currentSort: feed.sortBy,
                    ),
                    if (feed.sortFrom != null)
                      TimeSortButton(
                        onSortChanged: (TimeSort newSortFrom) {
                          context.then(Then(TransitionFeed(
                            feed: feed,
                            to: ListingStatus.refreshing,
                            sortFrom: newSortFrom,
                          )));
                        },
                        currentSort: feed.sortFrom!,
                      ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
      Expanded(child: ListingScrollView(
        listing: feed.listing,
        onTransitionListing: (ListingStatus to) {
          context.then(
            Then(TransitionFeed(
              feed: feed,
              to: to,
            )));
        },
        thingBuilder: (BuildContext context, Post post) {
          return PostTile(
            post: post,
            pathPrefix: "",
            includeSubredditName: true,
          );
        },
      )),
    ]);
  }
}
