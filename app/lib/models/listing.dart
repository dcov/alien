import 'package:mal/mal.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

part 'listing.g.dart';

enum ListingStatus {
  idle,
  refreshing,
  loadingMore,
}

abstract class Listing<T extends Thing> implements Model {

  factory Listing({
    ListingStatus status,
    List<T> things,
    Pagination pagination,
    Object latestTransitionMarker
  }) = _$Listing;

  ListingStatus status;

  List<T> get things;

  Pagination pagination;

  Object latestTransitionMarker;
}

