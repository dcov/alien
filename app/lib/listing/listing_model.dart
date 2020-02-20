import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import '../thing/thing_model.dart';
import '../widgets/scroll_offset.dart';

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

@abs
abstract class Listing implements Model {

  ListingMode mode;

  ListingStatus status;

  List<Thing> get things;

  Pagination pagination;

  ScrollOffset get offset;
}
