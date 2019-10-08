part of 'app.dart';

class InitResources extends Effect {

  const InitResources();

  @override
  Future<Event> perform(AppContainer container) {
    return container.scraper
        .init()
        .then((_) {
          return const InitializedResources();
        });
  }
}
