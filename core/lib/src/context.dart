import 'package:hive/hive.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';
import 'package:stash/stash_api.dart';

abstract class CoreContext {

  RedditApp get redditApp;

  RedditClient? get scriptClient;

  HiveInterface get hive;

  Scraper get scraper;

  Cache get cache;

  Future<void> init();
}
