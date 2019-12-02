part of 'listing.dart';

typedef ThingWidgetBuilder = Widget Function(
  BuildContext context,
  dynamic thing,
);

typedef UpdateCallback = void Function(ListingStatus status);

class ListingScrollable extends StatefulWidget {

  ListingScrollable({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onUpdateListing,
  }) : super(key: key);

  final Listing listing;

  final ThingWidgetBuilder builder;

  final UpdateCallback onUpdateListing;

  @override
  _ListingScrollableState createState() => _ListingScrollableState();
}

class _ListingScrollableState extends State<ListingScrollable>
    with ScrollOffsetMixin {

  @override
  ScrollOffset get offset => widget.listing.offset;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      final Listing listing = widget.listing;
      return PaddedScrollView(
        controller: controller,
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
