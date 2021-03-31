import 'package:reddit/reddit.dart' show SubredditData;

import '../model/subreddit.dart';

Subreddit subredditFromData(SubredditData data) {
  return Subreddit(
    kind: data.kind,
    id: data.id,
    bannerBackgroundColor: data.bannerBackgroundColor,
    bannerImageUrl: data.bannerImageUrl,
    iconImageUrl: data.iconImageUrl,
    name: data.displayName,
    primaryColor: data.primaryColor,
    userIsSubscriber: data.userIsSubscriber);
}
