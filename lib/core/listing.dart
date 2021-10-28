import 'package:muex/muex.dart';

import '../reddit/types.dart';
import '../reddit/utils.dart';

import 'thing.dart';

part 'listing.g.dart';

enum ListingStatus {
  idle,
  refreshing,
  loadingMore,
}

abstract class Listing<T extends Thing> implements Model {

  factory Listing({
    required ListingStatus status,
    List<T> things,
    required Pagination pagination,
    Object? latestTransitionMarker
  }) = _$Listing;

  ListingStatus get status;
  set status(ListingStatus value);

  List<T> get things;

  Pagination get pagination;
  set pagination(Pagination pagination);

  Object? get latestTransitionMarker;
  set latestTransitionMarker(Object? value);
}

typedef _ListingTransitionEffectFactory = Then Function(Page page, Object marker);

class TransitionListing implements Update {

  TransitionListing({
    required this.listing,
    required this.to,
    required this.forceIfRefreshing,
    required this.effectFactory
  }) : assert(to != ListingStatus.idle),
       assert(!forceIfRefreshing || to != ListingStatus.loadingMore);

  final Listing listing;

  /// The status to transition to.
  ///
  /// This value cannot be [ListingStatus.idle].
  final ListingStatus to;

  /// Whether to force the transition if we're transitioning to [ListingStatus.refreshing]
  ///
  /// This only applies if [to] == [ListingStatus.refreshing].
  final bool forceIfRefreshing;

  final _ListingTransitionEffectFactory effectFactory;

  @override
  Then update(_) {
    switch(to) {
      case ListingStatus.refreshing:
        // We can only transition to refreshing if we're not already refreshing, or if we're forcing a refresh.
        if (listing.status == ListingStatus.refreshing && !forceIfRefreshing)
          return Then.done();

        listing.pagination = Pagination();
        break;
      case ListingStatus.loadingMore:
        // We can only transition to loadingMore if we're idling
        if (listing.status != ListingStatus.idle)
          return Then.done();

        // We can transition to loadingMore so there should be a next page to transition to
        assert(listing.pagination.nextPageExists);
        break;
      case ListingStatus.idle:
        throw StateError('Cannot transition to ListingStatus.idle manually.');
    }

    /// Create a new marker to mark this transition instance.
    final transitionMarker = Object();

    listing..status = to
           ..latestTransitionMarker = transitionMarker;

    return effectFactory(listing.pagination.nextPage!, transitionMarker);
  }
}

typedef _ThingFactory<TD extends ThingData, T extends Thing> = T Function(TD data);

class FinishListingTransition<TD extends ThingData, T extends Thing> implements Update {

  FinishListingTransition({
    required this.listing,
    required this.transitionMarker,
    required this.data,
    required this.thingFactory
  });

  final Listing<T> listing;

  final Object transitionMarker;

  final ListingData<TD> data;

  final _ThingFactory<TD, T> thingFactory;

  @override
  Then update(_) {
    // If the latest marker isn't the marker
    // we have, then this transition has been overriden by a different transition, in which case we don't need to do
    // anything.
    if (transitionMarker == listing.latestTransitionMarker) {
      late Iterable<TD> things;
      switch (listing.status) {
        case ListingStatus.refreshing:
          listing.things.clear();
          things = data.things;
          break;
        case ListingStatus.loadingMore:
          /// Filter out any [Thing] items from [things] that are already in
          /// [listing.things] by comparing their [Thing.id] values.
          things = data.things.where((TD td) {
            for (final Thing t in listing.things) {
              if (t.id == td.id)
                return false;
            }
            return true;
          });
          break;
        case ListingStatus.idle:
          throw StateError('Cannot finish transitioning to ListingStatus.idle manually.');
      }

      listing..pagination = listing.pagination.forward(data)
             ..things.addAll(things.map(thingFactory))
             ..status = ListingStatus.idle
             ..latestTransitionMarker = null;
    }

    return Then.done();
  }
}

class ListingTransitionFailed implements Update {

  ListingTransitionFailed({
    required this.listing,
    required this.transitionMarker
  });

  final Listing listing;

  final Object transitionMarker;

  @override
  Then update(_) {
    if (transitionMarker == listing.latestTransitionMarker) {
      listing..status = ListingStatus.idle
             ..latestTransitionMarker = null;
    }

    return Then.done();
  }
}
