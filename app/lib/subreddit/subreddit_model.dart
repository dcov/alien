part of 'subreddit.dart';

abstract class Subreddit extends Thing {

  @override
  String get kind => 't5';

  String get name;
}
