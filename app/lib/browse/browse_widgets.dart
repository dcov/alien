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
      return CustomTile(
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
                    SubscriptionsSliver(
                      subscriptionsKey: browse.subscriptions.key,
                    ),
                  if (browse.defaults != null)
                    DefaultsSliver(
                      defaultsKey: browse.defaults.key,
                    ),
                ],
              ),
            )
          )
        ],
      );
    }
  );
}
