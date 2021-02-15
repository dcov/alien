import 'package:muex/muex.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../models/listing.dart';
import '../models/thing.dart';

typedef _ListingTransitionEffectFactory = Then Function(Page page, Object marker);

class TransitionListing implements Update {

  TransitionListing({
    @required this.listing,
    @required this.to,
    @required this.forceIfRefreshing,
    @required this.effectFactory
  }) : assert(listing != null),
       assert(to != null),
       assert(to != ListingStatus.idle),
       assert(forceIfRefreshing != null),
       assert(!forceIfRefreshing || to != ListingStatus.loadingMore),
       assert(effectFactory != null);

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
        assert(listing.pagination != null && listing.pagination.nextPageExists);
        break;
      default:
        break;
    }

    /// Create a new marker to mark this transition instance.
    final transitionMarker = Object();

    listing..status = to
           ..latestTransitionMarker = transitionMarker;

    return effectFactory(listing.pagination.nextPage, transitionMarker);
  }
}

typedef _ThingFactory<TD extends ThingData, T extends Thing> = T Function(TD data);

class FinishListingTransition<TD extends ThingData, T extends Thing> implements Update {

  FinishListingTransition({
    @required this.listing,
    @required this.transitionMarker,
    @required this.data,
    @required this.thingFactory
  }) : assert(listing != null),
       assert(transitionMarker != null),
       assert(data != null),
       assert(thingFactory != null);

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
      Iterable<TD> things;
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
        default:
          break;
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
    @required this.listing,
    @required this.transitionMarker
  }) : assert(listing != null),
       assert(transitionMarker != null);

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

