import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart' show HomeSort;

import '../post/post_model.dart';
import '../listing/listing_model.dart';

part 'home_model.g.dart';

abstract class Home implements Model {

  Listing<Post> posts;

  HomeSort sortBy;
}

