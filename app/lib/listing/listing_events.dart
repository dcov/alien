part of 'listing.dart';

abstract class LoadPage extends Event {

  const LoadPage();

  @protected
  Page loadPage(Listing listing, ListingStatus status) {
    assert(listing != null);
    assert(status != null);
    assert(status != ListingStatus.idle);

    switch(status) {
      case ListingStatus.loadingFirst:
        if (listing.status == ListingStatus.loadingFirst)
          return null;

        listing..status = ListingStatus.loadingFirst
               ..pagination = Pagination()
               ..things.clear();

        return listing.pagination.nextPage;
      case ListingStatus.loadingNext:
        assert(listing.pagination != null);
        assert(listing.pagination.nextPageExists);
        if (listing.status != ListingStatus.idle)
          return null;
        
        listing.status = ListingStatus.loadingNext;
        if (listing.mode == ListingMode.single)
          listing.things.clear();
        
        return listing.pagination.nextPage;
      case ListingStatus.loadingPrevious:
        assert(listing.pagination != null);
        assert(listing.pagination.previousPageExists);
        assert(listing.mode == ListingMode.single);
        if (listing.status != ListingStatus.idle)
          return null;
        
        listing..status = ListingStatus.loadingPrevious
               ..things.clear();
        
        return listing.pagination.previousPage;
      default:
        return null;
    }
  }
}

abstract class LoadPageSuccess extends Event {

  const LoadPageSuccess();

  @protected
  void loadPageSuccess(
      Listing listing,
      ListingStatus status,
      ListingData data,
      Thing mapper(dynamic data)) {
    assert(listing.pagination != null);
    assert(status != ListingStatus.idle);
    if (listing.status != status)
      return;
    
    Iterable<ThingData> tdi = data.things;
    switch (status) {
      case ListingStatus.loadingPrevious:
        listing.pagination = listing.pagination.backward(data);
        continue mapThings;
      case ListingStatus.loadingNext:
        tdi = tdi.where((ThingData td) {
          for (final Thing t in listing.things) {
            if (t.id == td.id)
              return false;
          }
          return true;
        });
        continue forward;
      forward:
      case ListingStatus.loadingFirst:
        listing.pagination = listing.pagination.forward(data);
        continue mapThings;
      mapThings:
      default:
        listing.things.addAll(tdi.map(mapper));
    }

    listing.status = ListingStatus.idle;
  }
}

