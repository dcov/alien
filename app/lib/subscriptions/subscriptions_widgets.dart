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
      title: Text('Subscriptions')
    );
  }
}

class SubscriptionsEntry extends RouterEntry {

  SubscriptionsEntry({ @required this.subscriptions });

  final Subscriptions subscriptions;

  @override
  Target get target => subscriptions;

  @override
  String get title => 'Subscriptions';

  @override
  List<Widget> buildTopActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.more_horiz),
      )
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
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

  @override
  List<Widget> buildBottomActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.more_vert)
      )
    ];
  }
}

