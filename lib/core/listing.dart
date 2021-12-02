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

abstract class Listing implements Model {

  factory Listing() {
    return _$Listing(
      status: ListingStatus.idle,
      pagination: Pagination(),
    );
  }

  ListingStatus get status;
  set status(ListingStatus value);

  List<String> get ids;

  Pagination get pagination;
  set pagination(Pagination pagination);

  Object? get latestTransitionMarker;
  set latestTransitionMarker(Object? value);
}

class TransitionListing implements Update {

  TransitionListing({
    required this.listing,
    required this.to,
    required this.forceIfRefreshing,
    required this.onRemoveIds,
    required this.onLoadPage,
  }) : assert(to != ListingStatus.idle),
       assert(!forceIfRefreshing || to == ListingStatus.refreshing);

  final Listing listing;

  // The ListingStatus to transition to. (Cannot be .idle)
  final ListingStatus to;

  /// Whether to force the transition if we're transitioning to [ListingStatus.refreshing]
  ///
  /// This only applies if [to] == [ListingStatus.refreshing].
  final bool forceIfRefreshing;

  final Update Function(List<String> ids) onRemoveIds;

  final Effect Function(Page page, Object marker) onLoadPage;

  @override
  Then update(_) {
    switch(to) {
      case ListingStatus.refreshing:
        // If we're already refreshing and we're not forced to re-refresh then we don't have
        // anything to do.
        if (listing.status == ListingStatus.refreshing && !forceIfRefreshing)
          return Then.done();

        final removedIds = listing.ids.toList();
        listing..status = to
               ..ids.clear()
               ..pagination = Pagination()
               ..latestTransitionMarker = Object();

        return Then.all({
          if (removedIds.isNotEmpty)
            onRemoveIds(removedIds),
          onLoadPage(listing.pagination.nextPage!, listing.latestTransitionMarker!),
        });
      case ListingStatus.loadingMore:
        // If we're already loading the next listing or refreshing then we should ignore this
        // update.
        if (listing.status != ListingStatus.idle)
          return Then.done();

        assert(listing.pagination.nextPageExists);

        listing..status = to
               ..latestTransitionMarker = Object();

        return Then(onLoadPage(listing.pagination.nextPage!, listing.latestTransitionMarker!));
      case ListingStatus.idle:
        throw StateError('TransitionListing cannot transition to .idle');
    }
  }
}

class FinishListingTransition<TD extends ThingData, T extends Thing> implements Update {

  FinishListingTransition({
    required this.listing,
    required this.transitionMarker,
    required this.data,
    required this.onAddNewThings,
  });

  final Listing listing;

  final Object transitionMarker;

  final ListingData<TD> data;

  final Update Function(List<TD> things, Then then) onAddNewThings;

  @override
  Then update(_) {
    // If the latest marker isn't the marker we have, then this transition has been overriden by a
    // different transition, in which case we don't need to do anything.
    if (transitionMarker != listing.latestTransitionMarker) {
      return Then.done();
    }

    listing.pagination = listing.pagination.forward(data);

    final newThings = data.things.toList();
    if (listing.status == ListingStatus.loadingMore) {
      for (var i = 0; i < newThings.length; ) {
        final thing = newThings[i];
        if (listing.ids.contains(thing.id)) {
          newThings.removeAt(i);
          continue;
        }

        i++;
      }
    }

    return Then(onAddNewThings(
      newThings,
      Then(_AddedNewThings(
        listing: listing,
        newIds: newThings.map((thing) => thing.id).toList(growable: false),
      )),
    ));
  }
}

class _AddedNewThings implements Update {

  _AddedNewThings({
    required this.listing,
    required this.newIds,
  });

  final Listing listing;

  final List<String> newIds;

  @override
  Then update(_) {
    listing..status = ListingStatus.idle
           ..ids.addAll(newIds)
           ..latestTransitionMarker = null;

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
