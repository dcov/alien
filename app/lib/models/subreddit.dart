import 'package:elmer/elmer.dart';

import 'thing.dart';

part 'subreddit.g.dart';

abstract class Subreddit extends Model implements Thing {

  factory Subreddit({
    bool userIsSubscriber,
    String name,
    String id,
    String kind,
  }) = _$Subreddit;

  String get name;

  bool userIsSubscriber;
}

