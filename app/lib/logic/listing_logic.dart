import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../models/listing_model.dart';
import '../models/thing_model.dart';

typedef _TransitionListingEffectFactory = Effect Function(Page page);

class TransitionListing implements Event {

  TransitionListing({
    @required this.listing,
    @required this.to,
    @required this.effectFactory
  }) : assert(to != ListingStatus.idle,
         'Can\'t transition a Listing to idle manually, it has to be as a result of a different transition.');

  final Listing listing;

  final ListingStatus to;

  final _TransitionListingEffectFactory effectFactory;

  @override
  Effect update(_) {

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

typedef _ThingFactory = Thing Function(dynamic data);

class TransitionListingSuccess implements Event {

  TransitionListingSuccess({
    @required this.listing,
    @required this.to,
    @required this.data,
    @required this.thingFactory
  }) : assert(to != ListingStatus.idle);

  final Listing listing;

  final ListingStatus to;

  final ListingData data;

  final _ThingFactory thingFactory;

  @override
  void update(_) {
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

class TransitionListingFailure implements Event {

  TransitionListingFailure({
    @required this.listing,
    @required this.to
  });

  final Listing listing;
  
  final ListingStatus to;

  @override
  void update(_) {
    // TODO: implement
  }
}

