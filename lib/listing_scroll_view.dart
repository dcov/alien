import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/listing.dart';
import 'core/thing.dart';

class ListingScrollView<T extends Thing> extends StatefulWidget {

  ListingScrollView({
    Key? key,
    required this.listing,
    required this.onTransitionListing,
    required this.thingBuilder,
  }) : super(key: key);

  final Listing listing;

  final void Function(ListingStatus to) onTransitionListing;

  final Widget Function(BuildContext context, String id) thingBuilder;

  @override
  _ListingScrollViewState<T> createState() => _ListingScrollViewState<T>();
}

class _ListingScrollViewState<T extends Thing> extends State<ListingScrollView<T>> {

  final _controller = ScrollController();
  var _trackOffset = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handlePositionChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePositionChange() {
    if (!_trackOffset)
      return;

    final ScrollMetrics metrics = _controller.position;
    if (metrics.pixels > (metrics.maxScrollExtent - 100)) {
      widget.onTransitionListing(ListingStatus.loadingMore);
    }
  }

  void _checkShouldHandlePositionChange(Listing listing) {
    _trackOffset = listing.status == ListingStatus.idle && 
                   listing.pagination.nextPageExists == true;
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        final Listing listing = widget.listing;
        _checkShouldHandlePositionChange(listing);
        return ListView.builder(
          controller: _controller,
          itemCount: listing.ids.length,
          itemBuilder: (BuildContext context, int index) {
            return widget.thingBuilder(context, listing.ids[index]);
          },
        );
      },
    );
  }
}
