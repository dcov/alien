part of 'app.dart';

class InitResources extends Effect {

  const InitResources();

  @override
  dynamic perform(Deps deps) async {
    await deps.scraper.init();
    return const InitializedResources();
  }
}

