import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show HomeSort;

import 'post_model.dart';
import 'listing_model.dart';

export 'post_model.dart';
export 'listing_model.dart';

part 'home_model.g.dart';

abstract class Home implements Model {

  factory Home() {
    return _$Home(
      listing: Listing<Post>(
        things: <Post>[]),
      sortBy: HomeSort.best);
  }

  Listing<Post> listing;

  HomeSort sortBy;
}

