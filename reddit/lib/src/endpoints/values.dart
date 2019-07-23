import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'values.g.dart';

// Values that are used as parameters by the interactors.
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

abstract class Param {
  String get name;
  String get value;
}

abstract class TimedParam implements Param {
  bool get isTimed;
}

class TimeSort extends EnumClass implements Param {
  static const TimeSort hour = _$timeParamHour;
  static const TimeSort day = _$timeParamDay;
  static const TimeSort week = _$timeParamWeek;
  static const TimeSort month = _$timeParamMonth;
  static const TimeSort year = _$timeParamYear;
  static const TimeSort all = _$timeParamAll;

  static BuiltSet<TimeSort> get values => _$timeParamValues;
  static TimeSort valueOf(String name) => _$timeParamValueOf(name);

  const TimeSort._(String name) : super(name);

  @override
  String get value => this.name;
}

class HomeSort extends EnumClass implements TimedParam {
  static const HomeSort best = _$homeSortBest;
  static const HomeSort hot = _$homeSortHot;
  static const HomeSort newest = _$homeSortNew;
  static const HomeSort controversial = _$homeSortControversial;
  static const HomeSort top = _$homeSortTop;
  static const HomeSort rising = _$homeSortRising;

  static BuiltSet<HomeSort> get values => _$homeSortValues;
  static HomeSort valueOf(String name) => _$homeSortValueOf(name); 

  const HomeSort._(String name) : super(name);

  @override
  bool get isTimed => this == controversial || this == top;

  @override
  String get name => this == newest ? 'new' : super.name;

  @override
  String get value => this.name;
}

class OriginalSort extends EnumClass implements TimedParam {
  static const OriginalSort hot = _$originalSortHot;
  static const OriginalSort newest = _$originalSortNew;
  static const OriginalSort controversial = _$originalSortControversial;
  static const OriginalSort top = _$originalSortTop;

  static BuiltSet<OriginalSort> get values => _$originalSortValues;
  static OriginalSort valueOf(String name) => _$originalSortValueOf(name);

  const OriginalSort._(String name) : super(name);

  @override
  bool get isTimed => this == controversial || this == top;

  @override
  String get name => this == newest ? 'new' : super.name;

  @override
  String get value => this.name;
}

class SubredditSort extends EnumClass implements TimedParam {
  static const SubredditSort hot = _$subredditSortHot;
  static const SubredditSort newest = _$subredditSortNew;
  static const SubredditSort controversial = _$subredditSortControversial;
  static const SubredditSort top = _$subredditSortTop;
  static const SubredditSort rising = _$subredditSortRising;

  static BuiltSet<SubredditSort> get values => _$subredditSortValues;
  static SubredditSort valueOf(String name) => _$subredditSortValueOf(name);

  const SubredditSort._(String name) : super(name);

  @override
  bool get isTimed => this == controversial || this == top;

  @override
  String get name => this == newest ? 'new' : super.name;

  @override
  String get value => this.name;
}

class CommentsSort extends EnumClass implements Param {
  static const CommentsSort best = _$commentsSortBest;
  static const CommentsSort top = _$commentsSortTop;
  static const CommentsSort newest = _$commentsSortNew;
  static const CommentsSort controversial = _$commentsSortControversial;
  static const CommentsSort old = _$commentsSortOld;
  static const CommentsSort qa = _$commetsSortQA;

  static BuiltSet<CommentsSort> get values => _$commentsSortValues;
  static CommentsSort valueOf(String name) => _$commentsSortValueOf(name);

  const CommentsSort._(String name) : super(name);

  @override
  String get name => this == newest ? 'new' : super.name;

  @override
  String get value => this == best ? 'confidence' : this.name;
}

class UserHistory extends EnumClass implements Param {
  static const UserHistory overview = _$userHistoryOverview;
  static const UserHistory submitted = _$userHistorySubmitted;
  static const UserHistory comments = _$userHistoryComments;
  static const UserHistory gilded = _$userHistoryGilded;

  static BuiltSet<UserHistory> get values => _$userHistoryValues;
  static UserHistory valueOf(String name) => _$userHistoryValueOf(name);

  const UserHistory._(String name) : super(name);

  @override
  String get value => this.name;
}

class MyHistory extends EnumClass implements Param {
  static const MyHistory upvoted = _$myHistoryUpvoted;
  static const MyHistory downvoted = _$myHistoryDownvoted;
  static const MyHistory hidden = _$myHistoryHidden;
  static const MyHistory saved = _$myHistorySaved;

  static BuiltSet<MyHistory> get values => _$myHistoryValues;
  static MyHistory valueOf(String name) => _$myHistoryValueOf(name);

  const MyHistory._(String name) : super(name);

  @override
  String get value => this.name;
}

class HistorySort extends EnumClass implements Param {
  static const HistorySort hot = _$historySortHot;
  static const HistorySort newest = _$historySortNew;
  static const HistorySort top = _$historySortTop;
  static const HistorySort controversial = _$historySortControversial;

  static BuiltSet<HistorySort> get values => _$historySortValues;
  static HistorySort valueOf(String name) => _$historySortValueOf(name);

  const HistorySort._(String name) : super(name);

  @override
  String get name => this == newest ? 'new' : super.name;

  @override
  String get value => this.name;
}

class MySubreddits extends EnumClass implements Param {
  static const MySubreddits subscriber = _$mySubredditsSubscriber;
  static const MySubreddits contributor = _$mySubredditsContributor;
  static const MySubreddits moderator = _$mySubredditsModerator;
  static const MySubreddits streams = _$mySubredditsStreams;

  static BuiltSet<MySubreddits> get values => _$mySubredditsValues;
  static MySubreddits valueOf(String name) => _$mySubredditsValueOf(name);

  const MySubreddits._(String name) : super(name);

  @override
  String get value => this.name;
}

class Subreddits extends EnumClass implements Param {
  static const Subreddits popular = _$subredditsPopular;
  static const Subreddits newest = _$subredditsNewest;
  static const Subreddits gold = _$subredditsGold;
  static const Subreddits defaults = _$subredditsDefaults;

  static BuiltSet<Subreddits> get values => _$subredditsValues;
  static Subreddits valueOf(String name) => _$subredditsValueOf(name);

  const Subreddits._(String name) : super(name);

  @override
  String get name => this == newest ? 'new' : this == defaults ? 'default' : super.name;

  @override
  String get value => this.name;
}