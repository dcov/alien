
abstract class RedditArg {

  const RedditArg._(this.name, [String? value])
    : this.value = value ?? name;

  final String name;

  final String value;

  @override
  String toString() => this.value;
}

class Scope extends RedditArg {
  static const Scope account = Scope._('account');
  static const Scope creddits = Scope._('creddits');
  static const Scope edit = Scope._('edit');
  static const Scope flair = Scope._('flair');
  static const Scope history = Scope._('history');
  static const Scope identity = Scope._('identity');
  static const Scope liveManage = Scope._('livemanage');
  static const Scope modConfig = Scope._('modconfig');
  static const Scope modContributors = Scope._('modcontributors');
  static const Scope modFlair = Scope._('modflair');
  static const Scope modLog = Scope._('modlog');
  static const Scope modMail = Scope._('modmail');
  static const Scope modOthers = Scope._('modothers');
  static const Scope modPosts = Scope._('modposts');
  static const Scope modSelf = Scope._('modself');
  static const Scope modWiki = Scope._('modwiki');
  static const Scope mySubreddits = Scope._('mysubreddits');
  static const Scope privateMessages = Scope._('privatemessages');
  static const Scope read = Scope._('read');
  static const Scope report = Scope._('report');
  static const Scope save = Scope._('save');
  static const Scope submit = Scope._('submit');
  static const Scope subscribe = Scope._('subscribe');
  static const Scope vote = Scope._('vote');
  static const Scope wikiEdit = Scope._('wikiedit');
  static const Scope wikiRead = Scope._('wikiread');

  const Scope._(String name) : super._(name);

  static const Iterable<Scope> values = const <Scope>{
    account, creddits, edit, flair, history, identity, liveManage, modConfig,
    modContributors, modFlair, modLog, modMail, modOthers, modPosts, modSelf,
    modWiki, mySubreddits, privateMessages, read, report, save, submit,
    subscribe, vote, wikiEdit, wikiRead
  };

  static Scope from(String value) {
    final String name = value.toLowerCase();
    for (final Scope scope in values) {
      if (scope.name == name) {
        return scope;
      }
    }
    throw ArgumentError('${value} was not a valid Scope name');
  }
}

class VoteDir extends RedditArg {
  static const VoteDir up = VoteDir._('up', '1');
  static const VoteDir down = VoteDir._('down', '-1');
  static const VoteDir none = VoteDir._('none', '0');

  const VoteDir._(String name, String value) : super._(name, value);
}

class TimeSort extends RedditArg {
  static const TimeSort hour = TimeSort._('hour');
  static const TimeSort day = TimeSort._('day');
  static const TimeSort week = TimeSort._('week');
  static const TimeSort month = TimeSort._('month');
  static const TimeSort year = TimeSort._('year');
  static const TimeSort all = TimeSort._('all');

  const TimeSort._(String name) : super._(name);
}

abstract class TimedParameter extends RedditArg {

  const TimedParameter._(this.isTimed, String name, [String? value]) : super._(name, value);

  final bool isTimed;
}

class HomeSort extends TimedParameter {
  static const HomeSort best = HomeSort._(false, 'best');
  static const HomeSort hot = HomeSort._(false, 'hot');
  static const HomeSort newest = HomeSort._(false, 'new');
  static const HomeSort controversial = HomeSort._(true, 'controversial');
  static const HomeSort top = HomeSort._(true, 'top');
  static const HomeSort rising = HomeSort._(false, 'rising');

  const HomeSort._(bool isTimed, String name) : super._(isTimed, name);
}

class OriginalSort extends TimedParameter {
  static const OriginalSort hot = OriginalSort._(false, 'hot');
  static const OriginalSort newest = OriginalSort._(false, 'new');
  static const OriginalSort controversial = OriginalSort._(true, 'controversial');
  static const OriginalSort top = OriginalSort._(true, 'top');

  const OriginalSort._(bool isTimed, String name) : super._(isTimed, name);
}

class SubredditSort extends TimedParameter {
  static const SubredditSort hot = SubredditSort._(false, 'hot');
  static const SubredditSort newest = SubredditSort._(false, 'new');
  static const SubredditSort controversial = SubredditSort._(true, 'controversial');
  static const SubredditSort top = SubredditSort._(true, 'top');
  static const SubredditSort rising = SubredditSort._(false, 'rising');

  const SubredditSort._(bool isTimed, String name) : super._(isTimed, name);
}

class CommentsSort extends RedditArg {
  static const CommentsSort best = CommentsSort._('best', 'confidence');
  static const CommentsSort top = CommentsSort._('top');
  static const CommentsSort newest = CommentsSort._('new');
  static const CommentsSort controversial = CommentsSort._('controversial');
  static const CommentsSort old = CommentsSort._('old');
  static const CommentsSort qa = CommentsSort._('qa');

  const CommentsSort._(String name, [String? value]) : super._(name, value);
}

class HistorySort extends RedditArg {
  static const HistorySort hot = HistorySort._('hot');
  static const HistorySort newest = HistorySort._('new');
  static const HistorySort top = HistorySort._('top');
  static const HistorySort controversial = HistorySort._('controversial');

  const HistorySort._(String name) : super._(name);
}

class Page extends RedditArg {

  static const kDefaultLimit = 25;
  static const kMaxLimit = 100;

  Page.next({
    required int limit,
    int? count,
    String? id
  }) : super._('limit=$limit' + (id != null ? '&count=$count&after=$id' : ''));
  
  Page.previous({
    required int limit,
    int? count,
    String? id
  }) : super._('limit=$limit' + (id != null ? '&count=$count&before=$id' : ''));

  Page({
    int limit = kDefaultLimit
  }) : super._('limit=$limit');
}

class AccountHistory extends RedditArg {
  static const AccountHistory overview = AccountHistory._('overview');
  static const AccountHistory submitted = AccountHistory._('submitted');
  static const AccountHistory comments = AccountHistory._('comments');
  static const AccountHistory gilded = AccountHistory._('gilded');

  const AccountHistory._(String name) : super._(name);
}

class UserHistory extends RedditArg {
  static const UserHistory upvoted = UserHistory._('upvoted');
  static const UserHistory downvoted = UserHistory._('downvoted');
  static const UserHistory hidden = UserHistory._('hidden');
  static const UserHistory saved = UserHistory._('saved');

  const UserHistory._(String name) : super._(name);
}

class Subreddits extends RedditArg {
  static const Subreddits popular = Subreddits._('popular');
  static const Subreddits newest = Subreddits._('new');
  static const Subreddits gold = Subreddits._('gold');
  static const Subreddits defaults = Subreddits._('default');

  const Subreddits._(String name) : super._(name);
}

class UserSubreddits extends RedditArg {
  static const UserSubreddits subscriber = UserSubreddits._('subscriber');
  static const UserSubreddits contributor = UserSubreddits._('contributor');
  static const UserSubreddits moderator = UserSubreddits._('moderator');
  static const UserSubreddits streams = UserSubreddits._('streams');

  const UserSubreddits._(String name) : super._(name);
}
