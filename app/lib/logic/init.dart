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

part 'init.msg.dart';

@initializer init({ @required String appId, @required String appRedirect }) {
  return Initialization(
    state: App(
      initialized: false,
      auth: Auth(
        appId: appId,
        appRedirect: appRedirect)),
    then: InitResources());
}

@effect initResources(EffectContext context) async {
  try {
    await context.scraper.init();

    final Directory appDir = await pathProvider.getApplicationDocumentsDirectory();
    context.hive.init(path.join(appDir.path, 'data'));

    return InitResourcesSuccess(
      users: await retrieveUsers(context),
      signedInUser: await retrieveSignedInUser(context));
  } catch (_) {
    return InitResourcesFail();
  }
}

@action initResourcesSuccess(App app, { @required Map<String, String> users, @required String signedInUser }) {
  app.initialized = true;

  return <Message>{
    InitAuth(
      users: users,
      signedInUser: signedInUser),
    UpdateTheme(theming: app.theming),
  };
}

@action initResourcesFail(_) {
  // TODO: implement
}
