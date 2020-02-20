import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/padded_scroll_view.dart';
import '../widgets/scroll_offset.dart';

import 'listing_model.dart';

typedef ThingWidgetBuilder = Widget Function(BuildContext context, dynamic thing);

typedef LoadPageCallback = void Function(ListingStatus status);

class ListingScrollView extends StatelessWidget {

  ListingScrollView({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onLoadPage,
  }) : super(key: key);

  final Listing listing;

  final ThingWidgetBuilder builder;

  final LoadPageCallback onLoadPage;

  @override
  Widget build(_) => Tracker(
    builder: (BuildContext context) {
      switch (listing.mode) {
        case ListingMode.endless:
          return _EndlessListingScrollView(
            listing: listing,
            builder: builder,
            onLoadPage: onLoadPage,
          );
        case ListingMode.single:
        default:
          return const SizedBox();
      }
    }
  );
}

class _EndlessListingScrollView extends StatefulWidget {

  _EndlessListingScrollView({
    Key key,
    @required this.listing,
    @required this.builder,
    @required this.onLoadPage
  }) : super(key: key);

  final Listing listing;

  final ThingWidgetBuilder builder;

  final LoadPageCallback onLoadPage;

  @override
  _EndlessListingScrollViewState createState() => _EndlessListingScrollViewState();
}

class _EndlessListingScrollViewState extends State<_EndlessListingScrollView>
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
      widget.onLoadPage(ListingStatus.loadingNext);
    }
  }

  @override
  void track(_) {
    final Listing listing = widget.listing;
    _trackOffset = listing.status == ListingStatus.idle && 
                   listing.pagination?.nextPageExists == true;
  }

  @override
  Widget build(_) {
    super.buildCheck();
    return Tracker(
      builder: (BuildContext context) {
        final Listing listing = widget.listing;
        return PaddedScrollView(
          controller: controller,
          slivers: <Widget>[
            if (listing.status == ListingStatus.loadingFirst)
              SliverToBoxAdapter(child: CircularProgressIndicator()),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widget.builder(context, listing.things[index]);
                },
                childCount: listing.things.length
              ),
            ),

            if (listing.status == ListingStatus.loadingNext)
              SliverToBoxAdapter(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}

