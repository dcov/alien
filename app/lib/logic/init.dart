import 'dart:io';

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
import '../models/defaults.dart';
import '../models/feed.dart';
import '../models/subscriptions.dart';
import '../models/theming.dart';

import 'auth.dart';
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
    print('InitApp');
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

class InitResources extends Effect {

  InitResources();

  @override
  dynamic perform(EffectContext context) async {
    print('InitResources');
    try {
      await context.scraper.init();

      //final Directory appDir = await pathProvider.getApplicationDocumentsDirectory();
      //context.hive.init(path.join(appDir.path, 'data'));

      return InitResourcesSuccess(
        users: null, //await retrieveUsers(context),
        signedInUser: null);//await retrieveSignedInUser(context));
    } catch (_) {
      return InitResourcesFailure();
    }
  }
}

class InitResourcesSuccess extends Action {

  InitResourcesSuccess({
    @required this.users,
    @required this.signedInUser
  });

  final Map<String, String> users;

  final String signedInUser;

  @override
  dynamic update(App app) {
    app.initialized = true;
    return <Message>{
      // InitAuth(
      // users: users,
      // signedInUser: signedInUser),
      UpdateTheme(theming: app.theming),
      ResetState()
    };
  }
}

class InitResourcesFailure extends Action {

  InitResourcesFailure();

  @override
  dynamic update(_) {
    // TODO: implement
  }
}

class ResetState extends Action {

  ResetState();

  @override
  dynamic update(App app) {
    app.feeds
      ..clear()
      ..add(Feed(type: FeedType.popular, sortBy: SubredditSort.hot))
      ..add(Feed(type: FeedType.all, sortBy: SubredditSort.hot));

    if (app.auth.currentUser == null) {
      app..subscriptions = null
         ..defaults = Defaults(refreshing: false)
         ..feeds.insert(0, Feed(type: FeedType.home, sortBy: HomeSort.best));
      return RefreshDefaults();
    } else {
      app..defaults = null
         ..subscriptions = Subscriptions(refreshing: false);
      return RefreshSubscriptions(); 
    }
  }
}

