import 'package:reddit/reddit.dart' show SubredditData;

import '../models/subreddit.dart';

Subreddit subredditFromData(SubredditData data) {
  return Subreddit(
    kind: data.kind,
    id: data.id,
    name: data.displayName,
    userIsSubscriber: data.userIsSubscriber);
}

