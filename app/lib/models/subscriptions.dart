import 'package:elmer/elmer.dart';

import 'subreddit.dart';

export 'subreddit.dart';

part 'subscriptions.mdl.dart';

@model
mixin $Subscriptions {

  bool refreshing;

  List<$Subreddit> get subreddits; 
}

