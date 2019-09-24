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
        onTap: () {
          dispatch(PushBrowse(browseKey: this.browseKey));
          PushNotification.notify(context);
        },
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

  TextEditingController _textController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Browse browse = store.get(widget.browseKey);
      return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: Colors.white,
          title: TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(4.0),
              hintText: 'Browse',
              border: InputBorder.none
            ),
            textInputAction: TextInputAction.search,
          )
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            if (browse.subscriptions != null)
              SubscriptionsSliver(
                subscriptionsKey: browse.subscriptions.key,
              ),
            if (browse.defaults != null)
              DefaultsSliver(
                defaultsKey: browse.defaults.key,
              ),
            SliverToBoxAdapter(child: SizedBox(height: 16.0))
          ],
        ),
      );
    }
  );
}
