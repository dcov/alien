part of 'subreddit_posts.dart';

class SubredditPostsScrollable extends StatelessWidget {

  SubredditPostsScrollable({
    Key key,
    @required this.subredditPosts,
    this.topPadding,
  }) : super(key: key);

  final SubredditPosts subredditPosts;

  final double topPadding;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, EventDispatch dispatch) {
      return ListingScrollable(
        listing: this.subredditPosts,
        topPadding: this.topPadding,
        builder: (_, Post post) => PostTile(post: post),
        onUpdateListing: (ListingStatus status) {
          dispatch(UpdateSubredditPosts(
            subredditPosts: this.subredditPosts,
            status: status
          ));
        },
      );
    }
  );
}
