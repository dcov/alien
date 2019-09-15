part of 'browse.dart';

class BrowseTile extends StatelessWidget {

  BrowseTile({
    Key key,
    @required this.browseKey,
  }) : super(key: key);

  final ModelKey browseKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      return ListTile(
        onTap: () => dispatch(PushBrowse(browseKey: this.browseKey)),
        title: Text('Browse'),
      );
    },
  );
}

class BrowsePage extends StatefulWidget {

  BrowsePage({
    Key key,
    @required this.browseKey
  }) : super(key: key);

  final ModelKey browseKey;

  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {

  @override
  Widget build(BuildContext context) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Browse browse = store.get(widget.browseKey);
      return Column(
        children: <Widget>[
          Material(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                height: 56.0,
                child: NavigationToolbar(
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      dispatch(PopBrowseTarget(browseKey: widget.browseKey));
                    }
                  ),
                  middle: Text('Browse'),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert),
                  ),
                )
              )
            )
          ),
          Expanded(
            child: Material(
              child: CustomScrollView(
                slivers: <Widget>[
                  if (browse.subscriptions != null)
                    _SubscriptionsSliver(
                      subscriptionsKey: browse.subscriptions.key,
                    )
                ],
              ),
            )
          )
        ],
      );
    }
  );
}

class _SubscriptionsSliver extends StatelessWidget {

  _SubscriptionsSliver({
    Key key,
    @required this.subscriptionsKey,
  }) : super(key: key);

  final ModelKey subscriptionsKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, Store store, EventDispatch dispatch) {
      final List<Subreddit> subscriptions = store.get<Subscriptions>(subscriptionsKey).subreddits;
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) {
          },
          childCount: subscriptions.length,
        ),
      );
    }
  );
}

class _DefaultsSliver extends StatelessWidget {

  _DefaultsSliver({
    Key key,
    @required this.defaultsKey
  }) : super(key: key);

  final ModelKey defaultsKey;

  @override
  Widget build(BuildContext context) => Connector(
    builder: (BuildContext _, Store store, EventDispatch dispatch) {
      final List<Subreddit> defaults = store.get<Defaults>(this.defaultsKey).subreddits;
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) { },
          childCount: defaults.length
        ),
      );
    },
  );
}
