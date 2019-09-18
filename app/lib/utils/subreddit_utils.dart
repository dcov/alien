part of 'utils.dart';

int compareSubreddits(Subreddit s1, Subreddit s2) {
  return s1.name.toLowerCase().compareTo(s2.name.toLowerCase());
}