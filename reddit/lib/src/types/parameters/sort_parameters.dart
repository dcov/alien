part of 'parameters.dart';

class TimeSort extends Parameter {
  static const TimeSort hour = TimeSort._('hour');
  static const TimeSort day = TimeSort._('day');
  static const TimeSort week = TimeSort._('week');
  static const TimeSort month = TimeSort._('month');
  static const TimeSort year = TimeSort._('year');
  static const TimeSort all = TimeSort._('all');

  const TimeSort._(String name) : super._(name);
}

abstract class TimedParameter extends Parameter {

  const TimedParameter._(this.isTimed, String name, [String value]) : super._(name, value);

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

class CommentsSort extends Parameter {
  static const CommentsSort best = CommentsSort._('best', 'confidence');
  static const CommentsSort top = CommentsSort._('top');
  static const CommentsSort newest = CommentsSort._('new');
  static const CommentsSort controversial = CommentsSort._('controversial');
  static const CommentsSort old = CommentsSort._('old');
  static const CommentsSort qa = CommentsSort._('qa');

  const CommentsSort._(String name, [String value]) : super._(name, value);
}

class HistorySort extends Parameter {
  static const HistorySort hot = HistorySort._('hot');
  static const HistorySort newest = HistorySort._('new');
  static const HistorySort top = HistorySort._('top');
  static const HistorySort controversial = HistorySort._('controversial');

  const HistorySort._(String name) : super._(name);
}

