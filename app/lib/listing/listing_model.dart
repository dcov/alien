import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';

import '../thing/thing_model.dart';
import '../widgets/scroll_offset.dart';

part 'listing_model.g.dart';

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

abstract class Listing<T extends Thing> implements Model {

  factory Listing({
    @required ListingMode mode,
    ListingStatus status = ListingStatus.idle,
    @required List<T> things,
    Pagination pagination,
    @required ScrollOffset offset,
  }) {
    assert(mode != null);
    assert(things != null);
    assert(offset != null);

    return _$Listing<T>(
      mode: mode,
      status: status,
      things: things,
      pagination: pagination,
      offset: offset);
  }

  ListingMode mode;

  ListingStatus status;

  List<T> get things;

  Pagination pagination;

  ScrollOffset get offset;
}
