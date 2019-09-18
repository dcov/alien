part of 'subscriptions.dart';

class SubscriptionsSliver extends StatelessWidget {

  SubscriptionsSliver({
    Key key,
    @required this.subscriptionsKey
  }) : super(key: key);

  final ModelKey subscriptionsKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Subscriptions subscriptions = store.get(this.subscriptionsKey);
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) => SubredditTile(
            subredditKey: subscriptions.subreddits[index].key),
          childCount: subscriptions.subreddits.length
        ),
      );
    }
  );
}
