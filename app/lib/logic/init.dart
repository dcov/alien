import 'package:mal/mal.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart' as cacheProvider;

import '../effects.dart';
import '../models/accounts.dart';
import '../models/app.dart';
import '../models/auth.dart';
import '../models/feed.dart';
import '../models/refreshable.dart';
import '../models/theming.dart';
import '../models/user.dart';

import 'accounts.dart';
import 'defaults.dart';
import 'subscriptions.dart';
import 'theming.dart';

class InitApp implements Initial {
  
  InitApp({
    @required this.appId,
    @required this.appRedirect,
    @required this.isInScriptMode
  }) : assert(appId != null),
       assert(appRedirect != null),
       assert(isInScriptMode != null);

  final String appId;

  final String appRedirect;

  final bool isInScriptMode;

  @override
  Init init() {
    return Init(
      state: App(
        initialized: false,
        accounts: Accounts(
          isInScriptMode: isInScriptMode),
        auth: Auth(
          appId: appId,
          appRedirect: appRedirect),
        theming: Theming()),
      then: Then(_InitEffectContext()));
  }
}

class _InitEffectContext implements Effect {

  _InitEffectContext();

  @override
  Future<Then> effect(EffectContext context) async {
    /// Initialize the scraper
    await context.scraper.init();

    /// Initialize the hive db instance
    context.hive.init(
        path.join((await pathProvider.getApplicationSupportDirectory()).path, 'db'));

    /// Initialize the cache instance
    context.cache = cacheProvider.newHiveCache(
        path.join((await pathProvider.getTemporaryDirectory()).path, 'cache'),
        cacheName: 'main',
        expiryPolicy: const TouchedExpiryPolicy(Duration(days: 2)),
        evictionPolicy: const LruEvictionPolicy());

    return Then(_InitCoreState());
  }
}

class _InitCoreState implements Update {

  _InitCoreState();

  @override
  Then update(App app) {
    return Then.all({
      UpdateTheme(theming: app.theming),
      InitAccounts(
        onInitialized: () => Then(_ResetUserState()),
        onFailed: () => Then(_ResetUserState())),
    });
  }
}

/// Switches the currently signed in user, and resets the main state of the application.
class SwitchUser implements Update {

  SwitchUser({ this.to });

  final User to;

  @override
  Then update(_) {
    return Then.all({
      SetCurrentUser(to: to),
      _ResetUserState()
    });
  }
}

class LogOutUser implements Update {

  LogOutUser({
    @required this.user
  }) : assert(user != null);

  final User user;

  @override
  Then update(App app) {
    return Then.all({
      if (app.accounts.currentUser == user)
        SwitchUser(to: null),
      RemoveUser(user: user)
    });
  }
}

class _ResetUserState implements Update {

  _ResetUserState();

  @override
  Then update(App app) {
    app.initialized = true;

    app.feeds
      ..clear()
      ..add(Feed.popular)
      ..add(Feed.all);

    if (app.accounts.currentUser == null) {
      app..subscriptions = null
         ..defaults = Refreshable(refreshing: false);
      return Then(RefreshDefaults(defaults: app.defaults));
    } else {
      app..defaults = null
         ..subscriptions = Refreshable(refreshing: false)
         ..feeds.insert(0, Feed.home);
      return Then(RefreshSubscriptions(subscriptions: app.subscriptions)); 
    }
  }
}

