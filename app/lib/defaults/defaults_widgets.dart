part of 'defaults.dart';

class DefaultsTile extends StatelessWidget {

  DefaultsTile({
    Key key,
    @required this.defaults
  }) : super(key: key);

  final Defaults defaults;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () => context.push(defaults),
      title: Text('Defaults')
    );
  }
}

class DefaultsEntry extends RouterEntry {

  DefaultsEntry({ @required this.defaults });

  final Defaults defaults;

  @override
  Target get target => this.defaults;

  @override
  String get title => 'Defaults';

  @override
  List<Widget> buildTopActions(BuildContext context) => <Widget>[
  ];

  @override
  Widget buildBody(BuildContext context) => Connector(
    builder: (_, __) {
      final List<Subreddit> subreddits = defaults.subreddits;
      return TrackingScrollView(
        offset: defaults.offset,
        slivers: <Widget>[
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, int index) => SubredditTile(subreddit: subreddits[index]),
            childCount: subreddits.length
          ))
        ]
      );
    }
  );

  @override
  List<Widget> buildBottomActions(BuildContext context) => <Widget>[
  ];
}

