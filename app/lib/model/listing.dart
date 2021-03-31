import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import '../model/thing.dart';

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
