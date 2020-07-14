part of 'parameters.dart';

class Page extends Parameter {

  static const kDefaultLimit = 25;
  static const kMaxLimit = 100;

  Page.next({ int limit, int count, String id }) :
      super._('limit=$limit' + (id != null ? '&count=$count&after=$id' : ''));
  
  Page.previous({ int limit, int count, String id })
    : super._('limit=$limit' + (id != null ? '&count=$count&before=$id' : ''));

  Page({ int limit = kDefaultLimit }) : super._('limit=$limit');
}

class AccountHistory extends Parameter {
  static const AccountHistory overview = AccountHistory._('overview');
  static const AccountHistory submitted = AccountHistory._('submitted');
  static const AccountHistory comments = AccountHistory._('comments');
  static const AccountHistory gilded = AccountHistory._('gilded');

  const AccountHistory._(String name) : super._(name);
}

class UserHistory extends Parameter {
  static const UserHistory upvoted = UserHistory._('upvoted');
  static const UserHistory downvoted = UserHistory._('downvoted');
  static const UserHistory hidden = UserHistory._('hidden');
  static const UserHistory saved = UserHistory._('saved');

  const UserHistory._(String name) : super._(name);
}

class Subreddits extends Parameter {
  static const Subreddits popular = Subreddits._('popular');
  static const Subreddits newest = Subreddits._('new');
  static const Subreddits gold = Subreddits._('gold');
  static const Subreddits defaults = Subreddits._('default');

  const Subreddits._(String name) : super._(name);
}

class UserSubreddits extends Parameter {
  static const UserSubreddits subscriber = UserSubreddits._('subscriber');
  static const UserSubreddits contributor = UserSubreddits._('contributor');
  static const UserSubreddits moderator = UserSubreddits._('moderator');
  static const UserSubreddits streams = UserSubreddits._('streams');

  const UserSubreddits._(String name) : super._(name);
}

