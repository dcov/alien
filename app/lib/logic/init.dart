import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;

import '../effects.dart';
import '../logic/defaults.dart';
import '../logic/subscriptions.dart';
import '../models/accounts.dart';
import '../models/app.dart';
import '../models/auth.dart';
import '../models/feed.dart';
import '../models/refreshable.dart';
import '../models/theming.dart';
import '../models/user.dart';

import 'accounts.dart';
import 'theming.dart';

class InitApp extends Initial {
  
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
      then: _InitEffectContext());
  }
}

class _InitEffectContext extends Effect {

  _InitEffectContext();

  @override
  dynamic perform(EffectContext context) async {
    /// Initialize the scraper
    await context.scraper.init();

    /// Initialize the hive db instance
    context.hive.init(path.join((await pathProvider.getApplicationSupportDirectory()).path, 'hive'));

    return _InitCoreState();
  }
}

class _InitCoreState extends Action {

  _InitCoreState();

  @override
  dynamic update(App app) {
    return {
      UpdateTheme(theming: app.theming),
      InitAccounts(
        onInitialized: () => _ResetUserState(),
        onFailed: () => _ResetUserState()),
    };
  }
}

/// Switches the currently signed in user, and resets the main state of the application.
class SwitchUser extends Action {

  SwitchUser({ this.to });

  final User to;

  @override
  dynamic update(App app) {
    return {
      SetCurrentUser(to: to),
      _ResetUserState()
    };
  }
}

class _ResetUserState extends Action {

  _ResetUserState();

  @override
  dynamic update(App app) {
    app.initialized = true;

    app.feeds
      ..clear()
      ..add(Feed.popular)
      ..add(Feed.all);

    if (app.accounts.currentUser == null) {
      app..subscriptions = null
         ..defaults = Refreshable(refreshing: false);
      return RefreshDefaults(defaults: app.defaults);
    } else {
      app..defaults = null
         ..subscriptions = Refreshable(refreshing: false)
         ..feeds.insert(0, Feed.home);
      return RefreshSubscriptions(subscriptions: app.subscriptions); 
    }
  }
}

