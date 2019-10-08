part of 'browse.dart';

class BrowsePage extends StatefulWidget {

  BrowsePage({
    Key key,
    @required this.browse
  }) : super(key: key);

  final Browse browse;

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
    builder: (BuildContext context, EventDispatch dispatch) {
      final Browse browse = widget.browse;
      return Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
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
              SubscriptionsSliver(subscriptions: browse.subscriptions),
            if (browse.defaults != null)
              DefaultsSliver(defaults: browse.defaults),
            SliverToBoxAdapter(child: SizedBox(height: 16.0))
          ],
        ),
      );
    }
  );
}

class BrowseTile extends StatelessWidget {

  BrowseTile({
    Key key,
    @required this.browse,
  }) : super(key: key);

  final Browse browse;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return CustomTile(
        onTap: () => PushNotification.notify(context, PushBrowse(browse: browse)),
        title: Text('Browse'),
      );
    },
  );
}
