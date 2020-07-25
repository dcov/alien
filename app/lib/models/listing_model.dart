import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import 'thing_model.dart';

export 'thing_model.dart';

part 'listing_model.g.dart';

enum ListingStatus {
  idle,
  refreshing,
  loadingMore,
}

abstract class Listing<T extends Thing> implements Model {

  factory Listing({
    ListingStatus status = ListingStatus.idle,
    @required List<T> things,
    Pagination pagination,
  }) {
    assert(status != null);
    assert(things != null);
    return _$Listing<T>(
      status: status,
      things: things,
      pagination: pagination);
  }

  ListingStatus status;

  List<T> get things;

  Pagination pagination;
}
