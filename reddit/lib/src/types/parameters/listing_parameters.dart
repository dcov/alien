part of '../parameters.dart';

class Page {

  static const kDefaultLimit = 25;
  static const kMaxLimit = 100;

  Page({ int limit = kDefaultLimit}) :
    _value = 'limit=$limit';

  Page.next({ int limit, int count, String id }) :
      _value = 'limit=$limit' + (id != null ? '&count=$count&after=$id' : '');
  
  Page.previous({ int limit, int count, String id }) :
     _value = 'limit=$limit' + (id != null ? '&count=$count&before=$id' : '');

  final String _value;

  @override
  String toString() => _value;
}

class UserHistory extends Parameter {
  static const UserHistory overview = UserHistory._('overview');
  static const UserHistory submitted = UserHistory._('submitted');
  static const UserHistory comments = UserHistory._('comments');
  static const UserHistory gilded = UserHistory._('gilded');

  const UserHistory._(String name) : super._(name);
}

class MyHistory extends Parameter {
  static const MyHistory upvoted = MyHistory._('upvoted');
  static const MyHistory downvoted = MyHistory._('downvoted');
  static const MyHistory hidden = MyHistory._('hidden');
  static const MyHistory saved = MyHistory._('saved');

  const MyHistory._(String name) : super._(name);
}

class MySubreddits extends Parameter {
  static const MySubreddits subscriber = MySubreddits._('subscriber');
  static const MySubreddits contributor = MySubreddits._('contributor');
  static const MySubreddits moderator = MySubreddits._('moderator');
  static const MySubreddits streams = MySubreddits._('streams');

  const MySubreddits._(String name) : super._(name);
}

class Subreddits extends Parameter {
  static const Subreddits popular = Subreddits._('popular');
  static const Subreddits newest = Subreddits._('new');
  static const Subreddits gold = Subreddits._('gold');
  static const Subreddits defaults = Subreddits._('default');

  const Subreddits._(String name) : super._(name);
}
