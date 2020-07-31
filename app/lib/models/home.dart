import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show HomeSort;

import 'post.dart';
import 'listing.dart';

export 'post.dart';
export 'listing.dart';

part 'home.g.dart';

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

