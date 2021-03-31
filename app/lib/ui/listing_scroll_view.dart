import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../model/listing.dart';
import '../model/thing.dart';

typedef TransitionListingCallback = void Function(ListingStatus to);

typedef ThingBuilder<T extends Thing> = Widget Function(BuildContext context, T thing);

typedef ListingScrollViewBuilder = Widget Function(
  BuildContext context,
  ScrollController controller,
  Widget refreshSliver,
  Widget listSliver);

class ListingScrollView<T extends Thing> extends StatefulWidget {

  ListingScrollView({
    Key? key,
    required this.listing,
    required this.onTransitionListing,
    required this.thingBuilder,
    this.scrollViewBuilder = defaultScrollViewBuilder
  }) : super(key: key);

  final Listing<T> listing;

  final TransitionListingCallback onTransitionListing;

  final ThingBuilder<T> thingBuilder;

  final ListingScrollViewBuilder scrollViewBuilder;

  static Widget defaultScrollViewBuilder(BuildContext _, ScrollController controller, Widget refreshSliver, Widget listSliver) {
    return CustomScrollView(
      controller: controller,
      slivers: <Widget>[
        refreshSliver,
        listSliver
      ]);
  }

  @override
  _ListingScrollViewState<T> createState() => _ListingScrollViewState<T>();
}

class _ListingScrollViewState<T extends Thing> extends State<ListingScrollView<T>> {

  late ScrollController _controller;

  late bool _trackOffset;

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
                   listing.pagination.nextPageExists == true;
  }

  Completer<void>? _refreshCompleter;

  Future<void> _handleRefresh() {
    if (_refreshCompleter == null) {
      _refreshCompleter = Completer<void>();
      widget.onTransitionListing(ListingStatus.refreshing);
    }
    return _refreshCompleter!.future;
  }

  void _checkShouldFinishRefresh(Listing<T> listing) {
    if (_refreshCompleter != null) {
      assert(listing.status != ListingStatus.loadingMore);
      if (listing.status == ListingStatus.idle) {
        _refreshCompleter!.complete();
        _refreshCompleter = null;
      }
    }
  }

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        final Listing<T> listing = widget.listing;
        _checkShouldHandlePositionChange(listing);
        _checkShouldFinishRefresh(listing);
        return widget.scrollViewBuilder(
          context,
          _controller,
          CupertinoSliverRefreshControl(
            onRefresh: _handleRefresh),
          SliverList(
            key: ValueKey(listing.latestTransitionMarker),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.thingBuilder(context, listing.things[index]);
              },
              childCount: listing.things.length)));
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshCompleter?.complete();
    super.dispose();
  }
}
