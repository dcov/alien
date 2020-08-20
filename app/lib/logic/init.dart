import 'dart:io';

import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;

import '../effects.dart';
import '../models/app.dart';
import '../models/auth.dart';

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
    return Init(
      state: App(
        initialized: false,
        auth: Auth(
          appId: appId,
          appRedirect: appRedirect)),
      then: InitResources());
  }
}

class InitResources extends Effect {

  InitResources();

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.scraper.init();

      final Directory appDir = await pathProvider.getApplicationDocumentsDirectory();
      context.hive.init(path.join(appDir.path, 'data'));

      return InitResourcesSuccess(
        users: await retrieveUsers(context),
        signedInUser: await retrieveSignedInUser(context));
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
      InitAuth(
        users: users,
        signedInUser: signedInUser),
      UpdateTheme(theming: app.theming),
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

