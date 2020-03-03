import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../thing/thing_model.dart';
import '../widgets/padded_scroll_view.dart';
import '../widgets/scroll_offset.dart';

import 'listing_model.dart';

typedef ThingWidgetBuilder<T extends Thing> = Widget Function(BuildContext context, T thing);

typedef UpdateListingCallback = void Function(ListingStatus newStatus);

class ListingScrollView<T extends Thing> extends StatefulWidget {

  ListingScrollView({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onUpdateListing
  }) : super(key: key);

  final Listing<T> listing;

  final ThingWidgetBuilder<T> builder;

  final UpdateListingCallback onUpdateListing;

  @override
  _ListingScrollViewState<T> createState() => _ListingScrollViewState<T>();
}

class _ListingScrollViewState<T extends Thing> extends State<ListingScrollView<T>>
    with TrackerStateMixin, ScrollOffsetMixin {

  @override
  ScrollOffset get offset => widget.listing.offset;

  bool _trackOffset = false;

  @override
  void didChangeOffset() {
    super.didChangeOffset();
    if (!_trackOffset)
      return;

    final ScrollMetrics metrics = controller.position;
    if (metrics.pixels > (metrics.maxScrollExtent - 100)) {
      widget.onUpdateListing(ListingStatus.loadingMore);
    }
  }

  @override
  void track(_) {
    final Listing<T> listing = widget.listing;
    _trackOffset = listing.status == ListingStatus.idle && 
                   listing.pagination?.nextPageExists == true;
  }

  @override
  Widget build(_) {
    super.buildCheck();
    return Tracker(
      builder: (BuildContext context) {
        final Listing<T> listing = widget.listing;
        return PaddedScrollView(
          controller: controller,
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

