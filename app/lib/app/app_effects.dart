part of 'app.dart';

class InitResources extends Effect with RetrieveUsers, RetrieveSignedInUser {

  const InitResources();

  @override
  dynamic perform(Deps deps) async {
    try {
      await deps.scraper.init();

      final Directory appDir = await pathProvider.getApplicationDocumentsDirectory();
      deps.hive.init(path.join(appDir.path, 'data'));

      return InitResourcesSuccess(
        users: await retrieveUsers(deps),
        signedInUser: await retrieveSignedInUser(deps),
      );
    } catch (_) {
      return InitResourcesFail();
    }
  }
}

