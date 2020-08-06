import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show HomeSort;

import 'post.dart';
import 'listing.dart';

export 'post.dart';
export 'listing.dart';

part 'home.mdl.dart';

@model
mixin $Home {

  $Listing<$Post> listing;

  HomeSort sortBy;
}

