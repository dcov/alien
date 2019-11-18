part of 'base.dart';

class Deps {

  Deps({
    @required this.client,
    @required this.hive,
    @required this.scraper
  });

  final RedditClient client;

  final HiveInterface hive;

  final Scraper scraper;
}

