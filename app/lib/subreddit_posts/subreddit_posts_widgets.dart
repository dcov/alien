part of 'subreddit_posts.dart';

class SubredditPostsScrollable extends StatelessWidget {

  SubredditPostsScrollable({
    Key key,
    @required this.subredditPosts,
  }) : super(key: key);

  final SubredditPosts subredditPosts;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, EventDispatch dispatch) {
      return ListingScrollable(
        listing: this.subredditPosts,
        builder: (_, post) => PostTile(post: post),
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
