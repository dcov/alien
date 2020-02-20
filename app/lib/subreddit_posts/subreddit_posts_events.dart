import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../listing/listing_events.dart';
import '../listing/listing_model.dart';
import '../post/post_model.dart';
import '../subreddit_posts/subreddit_posts_model.dart';

import 'subreddit_posts_effects.dart';

class LoadSubredditPosts extends LoadPage {

  const LoadSubredditPosts({
    @required this.subredditPosts,
    @required this.status
  });

  final SubredditPosts subredditPosts;

  final ListingStatus status;

  @override
  dynamic update(_) {
    final Page page = loadPage(subredditPosts, status);
    if (page != null) {
      return GetSubredditPosts(
        subredditPosts: subredditPosts,
        status: status,
        page: page
      );
    }
  }
}

class GetSubredditPostsSuccess extends LoadPageSuccess {

  GetSubredditPostsSuccess({
    @required this.subredditPosts,
    @required this.status,
    @required this.data,
  });

  final SubredditPosts subredditPosts;
  final ListingStatus status;
  final ListingData data;

  @override
  dynamic update(_) {
    loadPageSuccess(
      subredditPosts,
      status,
      data,
      (data) => Post.fromData(data)
    );
  }
}

class GetSubredditPostsFail extends Event {

  const GetSubredditPostsFail();

  @override
  dynamic update(_) { }
}

