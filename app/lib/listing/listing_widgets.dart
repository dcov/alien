part of 'listing.dart';

typedef ThingWidgetBuilder<T extends Thing> = Widget Function(
  BuildContext context,
  T thing,
);

typedef UpdateCallback = void Function(ListingStatus status);

class ListingScrollable<T extends Thing> extends StatefulWidget {

  ListingScrollable({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onUpdateListing,
    this.topPadding = 0,
  }) : super(key: key);

  final Listing listing;

  final ThingWidgetBuilder<T> builder;

  final UpdateCallback onUpdateListing;

  final double topPadding;

  @override
  _ListingScrollableState<T> createState() => _ListingScrollableState<T>();
}

class _ListingScrollableState<T extends Thing> extends State<ListingScrollable<T>> {

  ScrollController _controller;

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      final Listing listing = widget.listing;
      _controller ??= ScrollController(
        initialScrollOffset: listing.state.scrollOffset
      );

      return CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          if (widget.topPadding > 0)
            SliverToBoxAdapter(
              child: SizedBox(height: widget.topPadding),
            ),
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
