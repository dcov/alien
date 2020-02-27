import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../thing/thing_model.dart';

import 'listing_model.dart';

abstract class UpdateListing extends Event {

  const UpdateListing();

  @protected
  Page updateListing(Listing listing, ListingStatus newStatus) {
    assert(listing != null);
    assert(newStatus != null);
    assert(newStatus != ListingStatus.idle);

    switch(newStatus) {
      case ListingStatus.refreshing:
        // Check if the listing is already refreshing
        if (listing.status == ListingStatus.refreshing)
          return null;

        listing..status = ListingStatus.refreshing
               ..pagination = Pagination()
               ..things.clear();

        return listing.pagination.nextPage;
      case ListingStatus.loadingMore:
        assert(listing.pagination != null);
        assert(listing.pagination.nextPageExists);
        if (listing.status != ListingStatus.idle)
          return null;
        
        listing..status = ListingStatus.loadingMore
               ..things.clear();
        
        return listing.pagination.nextPage;
      default:
        return null;
    }
  }
}

abstract class UpdateListingSuccess extends Event {

  const UpdateListingSuccess();

  @protected
  void updateListingSuccess(
      Listing listing,
      ListingStatus expectedStatus,
      ListingData data,
      Thing mapper(dynamic data)) {
    assert(listing.pagination != null);
    assert(expectedStatus != null);
    assert(expectedStatus != ListingStatus.idle);
    if (listing.status != expectedStatus)
      return;
    
    Iterable<ThingData> newThings = data.things;
    switch (listing.status) {
      case ListingStatus.loadingMore:
        // Filter out any [Thing] items from [newThings] that are already in
        // [listing.things] by comparing their [Thing.id] values.
        newThings = newThings.where((ThingData td) {
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
        listing.things.addAll(newThings.map(mapper));
    }

    listing.status = ListingStatus.idle;
  }
}

