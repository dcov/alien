part of 'subreddit_posts.dart';

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
