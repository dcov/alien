part of 'app.dart';

class InitResources extends Effect {

  const InitResources();

  @override
  Future<Event> perform(Repo repo) {
    return repo
      .get<Scraper>()
      .init()
      .then((_) {
        return const ResourcesInitialized();
      });
  }
}
