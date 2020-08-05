import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

export 'thing.dart';

part 'listing.mdl.dart';

enum ListingStatus {
  idle,
  refreshing,
  loadingMore,
}

@model
mixin $Listing<T extends Thing> {

  ListingStatus status;

  List<T> get things;

  Pagination pagination;
}

