import 'package:reddit/reddit.dart' show SubredditData;

import '../models/subreddit.dart';

extension SubredditDataExtensions on SubredditData {

  Subreddit toModel() {
    return Subreddit(
      kind: this.kind,
      id: this.id,
      name: this.displayName,
      userIsSubscriber: this.userIsSubscriber
    );
  }
}

