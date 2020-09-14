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

    // ignore: missing_enum_constant_in_switch
    switch(to) {
      case ListingStatus.refreshing:
        // Check if the listing is already refreshing
        if (listing.status == ListingStatus.refreshing)
          return;

        listing..status = ListingStatus.refreshing
               ..pagination = Pagination()
               ..things.clear();

        return effectFactory(listing.pagination.nextPage);
      case ListingStatus.loadingMore:
        assert(listing.pagination != null);
        assert(listing.pagination.nextPageExists);
        if (listing.status != ListingStatus.idle)
          return null;
        
        listing.status = ListingStatus.loadingMore;
        
        return effectFactory(listing.pagination.nextPage);
    }
  }
}

typedef _ThingFactory<TD extends ThingData, T extends Thing> = T Function(TD data);

class TransitionListingSuccess<TD extends ThingData, T extends Thing> extends Action {

  TransitionListingSuccess({
    @required this.listing,
    @required this.to,
    @required this.data,
    @required this.thingFactory
  });

  final Listing<T> listing;

  final ListingStatus to;

  final ListingData<TD> data;

  final _ThingFactory<TD, T> thingFactory;

  @override
  dynamic update(_) {
    // If that status of the listing isn't what we're finishing transitioning to then this transition has been
    // overriden by a different transition, in which case we don't need to do anything.
    if (listing.status != to)
      return;
    
    Iterable<TD> things = data.things;
    if (listing.status == ListingStatus.loadingMore) {
      /// Filter out any [Thing] items from [things] that are already in
      /// [listing.things] by comparing their [Thing.id] values.
      things = things.where((TD td) {
        for (final Thing t in listing.things) {
          if (t.id == td.id)
            return false;
        }
        return true;
      });
    }

    listing..pagination = listing.pagination.forward(data)
           ..things.addAll(things.map(thingFactory))
           ..status = ListingStatus.idle;
  }
}

class TransitionListingFailure extends Action {

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

