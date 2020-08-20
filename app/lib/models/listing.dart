import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

part 'listing.g.dart';

enum ListingStatus {
  idle,
  refreshing,
  loadingMore,
}

abstract class Listing<T extends Thing> extends Model {

  factory Listing({
    ListingStatus status,
    List<T> things,
    Pagination pagination
  }) = _$Listing;

  ListingStatus status;

  List<T> get things;

  Pagination pagination;
}

