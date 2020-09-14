import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../models/thing.dart';


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

class _ListingScrollViewState<T extends Thing> extends State<ListingScrollView<T>> {

  ScrollController _controller;

  bool _trackOffset;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_handlePositionChange);
    _trackOffset = false;
  }

  void _handlePositionChange() {
    if (!_trackOffset)
      return;

    final ScrollMetrics metrics = _controller.position;
    if (metrics.pixels > (metrics.maxScrollExtent - 100)) {
      widget.onTransitionListing(ListingStatus.loadingMore);
    }
  }

  void _checkShouldHandlePositionChange(Listing<T> listing) {
    _trackOffset = listing.status == ListingStatus.idle && 
                   listing.pagination?.nextPageExists == true;
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        final Listing<T> listing = widget.listing;
        _checkShouldHandlePositionChange(listing);
        return CustomScrollView(
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

