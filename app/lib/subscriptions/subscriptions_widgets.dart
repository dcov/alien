part of 'subscriptions.dart';

class SubscriptionsTile extends StatelessWidget {

  SubscriptionsTile({
    Key key,
    @required this.subscriptions
  }) : super(key: key);

  final Subscriptions subscriptions;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () => context.push(subscriptions),
      title: Text('Subscriptions')
    );
  }
}

class SubscriptionsEntry extends TargetEntry {

  SubscriptionsEntry({ @required this.subscriptions });

  final Subscriptions subscriptions;

  @override
  Target get target => subscriptions;

  @override
  String get title => 'Subscriptions';

  @override
  Widget buildBody(_) => Connector(
    builder: (_, __) {
      final List<Subreddit> subreddits = subscriptions.subreddits;
      return TrackingScrollView(
        offset: subscriptions.offset,
        slivers: <Widget>[
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, int index) => SubredditTile(subreddit: subreddits[index]),
            childCount: subreddits.length
          ))
        ]
      );
    }
  );
}

