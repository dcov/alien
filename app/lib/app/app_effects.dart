part of 'app.dart';

class InitResources extends Effect {

  const InitResources();

  @override
  Future<Event> perform(Deps deps) {
    return deps.scraper
        .init()
        .then((_) {
          return const InitializedResources();
        });
  }
}

