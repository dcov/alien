part of 'subscriptions.dart';

class SubscriptionsSliver extends StatelessWidget {

  SubscriptionsSliver({
    Key key,
    @required this.subscriptions
  }) : super(key: key);

  final Subscriptions subscriptions;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) => SubredditTile(
            subreddit: subscriptions.subreddits[index]),
          childCount: subscriptions.subreddits.length
        ),
      );
    }
  );
}
