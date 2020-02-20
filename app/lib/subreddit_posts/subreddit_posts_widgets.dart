import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

import '../listing/listing_model.dart';
import '../listing/listing_widgets.dart';
import '../post/post_widgets.dart';

import 'subreddit_posts_events.dart';
import 'subreddit_posts_model.dart';

class SubredditPostsScrollView extends StatelessWidget {

  SubredditPostsScrollView({
    Key key,
    @required this.subredditPosts,
  }) : super(key: key);

  final SubredditPosts subredditPosts;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, EventDispatch dispatch) {
      return ListingScrollView(
        listing: subredditPosts,
        builder: (_, post) {
          return PostTile(
            post: post,
            layout: PostTileLayout.list,
            includeSubredditName: false
          );
        },
        onLoadPage: (ListingStatus status) {
          dispatch(LoadSubredditPosts(
            subredditPosts: subredditPosts,
            status: status
          ));
        },
      );
    }
  );
}
