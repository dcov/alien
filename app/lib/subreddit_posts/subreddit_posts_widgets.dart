part of 'subreddit_posts.dart';

class SubredditPostsScrollable extends StatelessWidget {

  SubredditPostsScrollable({
    Key key,
    @required this.subredditPostsKey,
    this.topPadding,
  }) : super(key: key);

  final ModelKey subredditPostsKey;

  final double topPadding;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, Store __, EventDispatch dispatch) {
      return ListingScrollable(
        listingKey: this.subredditPostsKey,
        topPadding: this.topPadding,
        builder: (_, Thing thing) => PostTile(postKey: thing.key),
        onUpdateListing: (ListingStatus status) {
          dispatch(UpdateSubredditPosts(
            subredditPostsKey: this.subredditPostsKey,
            status: status
          ));
        },
      );
    }
  );
}
