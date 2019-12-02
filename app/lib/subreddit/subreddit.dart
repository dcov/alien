import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../auth/auth.dart';
import '../base/base.dart';
import '../listing/listing.dart';
import '../routing/routing.dart';
import '../subreddit_posts/subreddit_posts.dart';
import '../thing/thing.dart';
import '../user/user.dart';

part 'subreddit_effects.dart';
part 'subreddit_events.dart';
part 'subreddit_model.dart';
part 'subreddit_widgets.dart';
part 'subreddit.g.dart';

int compareSubreddits(Subreddit s1, Subreddit s2) {
  return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
}

