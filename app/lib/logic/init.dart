import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:reddit/reddit.dart';

import '../effects.dart';
import '../logic/defaults.dart';
import '../logic/subscriptions.dart';
import '../models/app.dart';
import '../models/auth.dart';
import '../models/feed.dart';
import '../models/refreshable.dart';
import '../models/theming.dart';

import 'accounts.dart';
import 'theming.dart';

class InitApp extends Initial {
  
  InitApp({
    @required this.appId,
    @required this.appRedirect
  });

  final String appId;

  final String appRedirect;

  @override
  Init init() {
    return Init(
      state: App(
        initialized: false,
        auth: Auth(
          appId: appId,
          appRedirect: appRedirect),
        theming: Theming()),
      then: InitResources());
  }
}

@visibleForTesting
class InitResources extends Effect {

  InitResources();

  @override
  dynamic perform(EffectContext context) async {
    try {
      /// Initialize the scraper
      await context.scraper.init();

      /// Initialize the hive db instance
      final appDir = await pathProvider.getApplicationDocumentsDirectory();
      final appHivePath = path.join(appDir.path, 'data');
      context.hive.init(appHivePath);

      return InitResourcesSuccess();
    } catch (_) {
      return InitResourcesFailure();
    }
  }
}

@visibleForTesting
class InitResourcesSuccess extends Action {

  InitResourcesSuccess();

  @override
  dynamic update(App app) {
    return <Message>{
      InitAccounts(
        onInitialized: () => InitMainState(),
        onFailed: () => InitMainState()),
      UpdateTheme(theming: app.theming),
    };
  }
}

@visibleForTesting
class InitResourcesFailure extends Action {

  InitResourcesFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class InitMainState extends Action {

  InitMainState();

  @override
  dynamic update(App app) {
    app.initialized = true;

    app.feeds
      ..clear()
      ..add(Feed(type: FeedType.popular, sortBy: SubredditSort.hot))
      ..add(Feed(type: FeedType.all, sortBy: SubredditSort.hot));

    if (app.accounts.currentUser == null) {
      app..subscriptions = null
         ..defaults = Refreshable(refreshing: false)
         ..feeds.insert(0, Feed(type: FeedType.home, sortBy: HomeSort.best));
      return RefreshDefaults(defaults: app.defaults);
    } else {
      app..defaults = null
         ..subscriptions = Refreshable(refreshing: false);
      return RefreshSubscriptions(subscriptions: app.subscriptions); 
    }
  }
}

