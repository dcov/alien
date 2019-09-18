part of 'listing.dart';

typedef ThingWidgetBuilder = Widget Function(BuildContext context, Thing thing);

typedef UpdateCallback = void Function(ListingStatus status);

class ListingScrollable extends StatefulWidget {

  ListingScrollable({
    Key key,
    @required this.listingKey,
    @required this.builder,
    @required this.onUpdateListing
  }) : super(key: key);

  final ModelKey listingKey;

  final ThingWidgetBuilder builder;

  final UpdateCallback onUpdateListing;

  @override
  _ListingScrollableState createState() => _ListingScrollableState();
}

class _ListingScrollableState extends State<ListingScrollable> {

  ScrollController _controller;

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Listing listing = store.get(widget.listingKey);
      _controller ??= ScrollController(
        initialScrollOffset: listing.state.scrollOffset
      );

      return CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.builder(context, listing.things[index]);
              },
              childCount: listing.things.length
            ),
          )
        ],
      );
    },
  );
}
