part of 'listing.dart';

enum ListingMode {
  single,
  endless,
}

enum ListingStatus {
  idle,
  loadingFirst,
  loadingNext,
  loadingPrevious
}

class ListingState { 

  double scrollOffset = 0;
}

@abs
abstract class Listing implements Model {

  ListingMode mode;

  ListingStatus status;

  List<Thing> get things;

  Pagination pagination;

  ListingState get state;
}
