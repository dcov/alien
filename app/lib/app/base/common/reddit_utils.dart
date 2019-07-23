import 'package:reddit/values.dart';

int compareSubreddits(Subreddit s1, Subreddit s2) {
  return s1.displayName.toLowerCase().compareTo(s2.displayName.toLowerCase());
}

List<Subreddit> sortSubreddits(List<Subreddit> list) {
  return list..sort(compareSubreddits);
}