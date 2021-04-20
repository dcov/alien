import 'package:alien_core/alien_core.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart' as cacheProvider;

class UIContext implements CoreContext {

  UIContext({
    required this.appId,
    required this.appRedirect,
    this.scriptId,
    this.scriptSecret,
    this.scriptUsername,
    this.scriptPassword,
  });

  final String appId; 

  final String appRedirect;

  final String? scriptId;

  final String? scriptSecret;

  final String? scriptUsername;

  final String? scriptPassword;

  late final RedditApp redditApp;

  late final RedditClient? scriptClient;

  late final HiveInterface hive;

  late final Scraper scraper;

  late final Cache cache;

  @override
  Future<void> init() async {
    // Since path_provider accesses the binary messenger service we need to ensure it's initialized before we use it.
    WidgetsFlutterBinding.ensureInitialized();

    final ioClient = Client();

    redditApp = RedditApp(
        clientId: appId,
        redirectUri: appRedirect,
        ioClient: ioClient);

    if (scriptId != null) {
      scriptClient = createScriptClient(
          clientId: scriptId!,
          clientSecret: scriptSecret!,
          username: scriptUsername!,
          password: scriptPassword!,
          ioClient: ioClient);
    }

    hive = Hive;
    hive.init(
        path.join((await pathProvider.getApplicationSupportDirectory()).path, 'db'));

    scraper = Scraper();
    await scraper.init();

    cache = cacheProvider.newHiveCache(
        path.join((await pathProvider.getTemporaryDirectory()).path, 'cache'),
        cacheName: 'main',
        expiryPolicy: const TouchedExpiryPolicy(Duration(days: 2)),
        evictionPolicy: const LruEvictionPolicy());
  }
}
