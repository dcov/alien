import 'package:reddit/reddit.dart' show SubredditData;

import '../subreddit_posts/subreddit_posts_model.dart';
import '../thing/thing_model.dart';

part 'subreddit_model.g.dart';

abstract class Subreddit implements Thing {

  factory Subreddit.fromData(SubredditData data) {
    return _$Subreddit(
      name: data.displayName,
      userIsSubscriber: data.userIsSubscriber,
    );
  }

  String get name;

  SubredditPosts posts;

  bool userIsSubscriber;
}
