import 'dart:io' show Directory;

import 'package:elmer/elmer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;

import '../auth/auth_effects.dart';
import '../effects/effect_context.dart';

import 'app_events.dart';

class InitResources extends Effect with RetrieveUsers, RetrieveSignedInUser {

  const InitResources();

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

