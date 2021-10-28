import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart' as cacheProvider;

import '../reddit/client.dart';

class CoreContext {

  CoreContext({
    required this.appId,
    required this.appRedirect,
    this.scriptId,
    this.scriptSecret,
    this.scriptUsername,
    this.scriptPassword,
  });

  late final Client httpClient;

  final String appId; 

  final String appRedirect;

  late final Reddit reddit;

  final String? scriptId;

  final String? scriptSecret;

  final String? scriptUsername;

  final String? scriptPassword;

  late final RedditClient? redditScriptClient;

  late final HiveInterface hive;

  late final Cache cache;

  Future<void> init() async {
    // Since path_provider accesses the binary messenger service we need to ensure it's initialized before we use it.
    WidgetsFlutterBinding.ensureInitialized();

    httpClient = Client();

    reddit = Reddit(
      clientId: appId,
      redirectUri: appRedirect,
      ioClient: httpClient
    );

    if (scriptId != null) {
      redditScriptClient = createScriptClient(
        clientId: scriptId!,
        clientSecret: scriptSecret!,
        username: scriptUsername!,
        password: scriptPassword!,
        ioClient: httpClient
      );
    } else {
      redditScriptClient = null;
    }

    hive = Hive;
    hive.init(path.join((await pathProvider.getApplicationSupportDirectory()).path, 'db'));

    cache = cacheProvider.newHiveCache(
      path: path.join((await pathProvider.getTemporaryDirectory()).path, 'cache'),
      cacheName: 'main',
      expiryPolicy: const TouchedExpiryPolicy(Duration(days: 2)),
      evictionPolicy: const LruEvictionPolicy()
    );
  }
}
