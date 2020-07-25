import 'dart:io';

import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;

import '../effects/effect_context.dart';
import '../models/app_model.dart';
import '../models/auth_model.dart';

class InitApp implements Initial {

  InitApp({
    @required this.appId,
    @required this.appRedirect
  }) : assert(appId != null),
       assert(appRedirect != null);

  final String appId;

  final String appRedirect;

  @override
  InitialResult init() {
    return InitialResult(
      state: App(
        initialized: false,
        auth: Auth(
          appId: appId,
          appRedirect: appRedirect)),
      then: InitResources());
  }
}

class InitResources implements Effect {

  InitResources();

  @override
  dynamic perform(EffectContext context) async {
    try {
      await context.scraper.init();

      final Directory appDir = await pathProvider.getApplicationDocumentsDirectory();
      context.hive.init(path.join(appDir.path, 'data'));

      return InitResourcesSuccess(
        users: await retrieveUsers(context),
        signedInUser: await retrieveSignedInUser(context),
      );
    } catch (_) {
      return InitResourcesFail();
    }
  }
}

class InitResourcesSuccess implements Event {

  InitResourcesSuccess({
    @required this.users,
    @required this.signedInUser,
  });

  final Map<String, String> users;

  final String signedInUser;

  @override
  dynamic update(App app) {
    app.initialized = true;

    return <Message>{
      InitAuth(
        users: users,
        signedInUser: signedInUser,
      ),
      InitBrowse(),
      UpdateTheme(theming: app.theming),
      ResetState()
    };
  }
}

class InitResourcesFail implements Event {

  InitResourcesFail();

  /// TODO: Implement
  @override
  dynamic update(_) {
  }
}
