import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import '../models/thing_model.dart';
import '../widgets/padded_scroll_view.dart';


typedef ThingWidgetBuilder<T extends Thing> = Widget Function(BuildContext context, T thing);

typedef TransitionListingCallback = void Function(ListingStatus to);

class ListingScrollView<T extends Thing> extends StatefulWidget {

  ListingScrollView({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onTransitionListing
  }) : super(key: key);

  final Listing<T> listing;

  final ThingWidgetBuilder<T> builder;

  final TransitionListingCallback onTransitionListing;

  @override
  _ListingScrollViewState<T> createState() => _ListingScrollViewState<T>();
}

class _ListingScrollViewState<T extends Thing> extends State<ListingScrollView<T>>
    with ConnectionStateMixin {

  ScrollController _controller;

  bool _trackOffset;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_handlePositionChange);
    _trackOffset = false;
    super.initState();
  }

  void _handlePositionChange() {
    if (!_trackOffset)
      return;

    final ScrollMetrics metrics = _controller.position;
    if (metrics.pixels > (metrics.maxScrollExtent - 100)) {
      widget.onTransitionListing(ListingStatus.loadingMore);
    }
  }

  @override
  void didUpdate(_) {
    final Listing<T> listing = widget.listing;
    _trackOffset = listing.status == ListingStatus.idle && 
                   listing.pagination?.nextPageExists == true;
  }

  @override
  Widget build(_) {
    super.buildCheck();
    return Connector(
      builder: (BuildContext context) {
        final Listing<T> listing = widget.listing;
        return PaddedScrollView(
          controller: _controller,
          slivers: <Widget>[
            if (listing.status == ListingStatus.refreshing)
              SliverToBoxAdapter(child: CircularProgressIndicator()),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widget.builder(context, listing.things[index]);
                },
                childCount: listing.things.length)),

            if (listing.status == ListingStatus.loadingMore)
              SliverToBoxAdapter(child: CircularProgressIndicator()),
          ]);
      });
  }
}

