import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../models/listing.dart';
import '../models/thing.dart';

typedef _TransitionListingEffectFactory = Effect Function(Page page);

class TransitionListing extends Action {

  TransitionListing({
    @required this.listing,
    @required this.to,
    @required this.effectFactory
  });

  final Listing listing;

  final ListingStatus to;

  final _TransitionListingEffectFactory effectFactory;

  @override
  dynamic update(_) {
    assert(to != ListingStatus.idle,
        'Can\'t transition a Listing to idle manually, it has to be as a result of a different transition.');

    switch(to) {
      case ListingStatus.refreshing:
        // Check if the listing is already refreshing
        if (listing.status == ListingStatus.refreshing)
          return null;

        listing..status = ListingStatus.refreshing
               ..pagination = Pagination()
               ..things.clear();

        return effectFactory(listing.pagination.nextPage);
      case ListingStatus.loadingMore:
        assert(listing.pagination != null);
        assert(listing.pagination.nextPageExists);
        if (listing.status != ListingStatus.idle)
          return null;
        
        listing..status = ListingStatus.loadingMore
               ..things.clear();
        
        return effectFactory(listing.pagination.nextPage);
      default:
        return null;
    }
  }
}

typedef _ThingFactory<TD extends ThingData> = Thing Function(TD data);

class TransitionListingSuccess<TD extends ThingData> extends Action {

  TransitionListingSuccess({
    @required this.listing,
    @required this.to,
    @required this.data,
    @required this.thingFactory
  });

  final Listing listing;

  final ListingStatus to;

  final ListingData<TD> data;

  final _ThingFactory<TD> thingFactory;

  @override
  dynamic update(_) {
    // If that status of the listing isn't what we're finishing transitioning to then this transition has been
    // overriden by a different transition, in which case we don't need to do anything.
    if (listing.status != to)
      return;
    
    Iterable<ThingData> things = data.things;
    switch (listing.status) {
      case ListingStatus.loadingMore:
        // Filter out any [Thing] items from [newThings] that are already in
        // [listing.things] by comparing their [Thing.id] values.
        things = things.where((ThingData td) {
          for (final Thing t in listing.things) {
            if (t.id == td.id)
              return false;
          }
          return true;
        });

        continue update;
      update:
      default:
        listing.pagination = listing.pagination.forward(data);
        listing.things.addAll(things.map(thingFactory));
    }

    listing.status = ListingStatus.idle;
  }
}

class TransitionListingFailure extends Action {

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

