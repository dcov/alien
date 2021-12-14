import 'core/post.dart';
import 'core/subreddit.dart';

import 'page_stack.dart';

String idFromObject(Object obj) {
  if (obj is Post) {
    return 'post:${obj.id}';
  } else if (obj is Subreddit) {
    return 'subreddit:${obj.id}';
  }

  throw UnimplementedError();
}

PageStackEntry pageFromId(
  String id, {
  required PageStackEntry onPostPage(),
  required PageStackEntry onSubredditPage(),
}) {
  final parts = id.split(':');
  switch (parts[0]) {
    case 'post':
      return onPostPage();
    case 'subreddit':
      return onSubredditPage();
  }

  throw UnimplementedError();
}
