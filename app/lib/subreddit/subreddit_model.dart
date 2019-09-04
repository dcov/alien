part of 'subreddit.dart';

class Subreddit extends Thing {

  Subreddit({
    String id,
    this.name,
  }) : super(id);

  @override
  String get kind => 't5';

  final String name;
}
