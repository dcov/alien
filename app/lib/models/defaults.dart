import 'package:elmer/elmer.dart';

import 'subreddit.dart';

export 'subreddit.dart';

part 'defaults.mdl.dart';

@model
mixin $Defaults {

  bool refreshing;

  List<$Subreddit> get subreddits;
}

