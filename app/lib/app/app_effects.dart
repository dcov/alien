part of 'app.dart';

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

class RenderUserChange extends Effect {

  const RenderUserChange({ @required this.app });

  final App app;

  @override
  dynamic perform(EffectContext context) {
    final AppRenderer renderer = context.renderer.withId(app);
    renderer?.renderUserChange();
  }
}

