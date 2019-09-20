part of 'app.dart';

class InitApp extends Event {

  const InitApp();

  @override
  Effect update(Store store) {
    store.get<AppState>()
        ..initialized = false;

    store.get<Theming>()
        ..type = ThemeType.light
        ..data = ThemeData.light();

    store.get<Routing>()
        ..targets.add(Browse()..depth = 0);
    
    return const InitResources();
  }
}

class ResourcesInitialized extends Event {

  const ResourcesInitialized();

  void update(Store store) {
    store.get<AppState>()
        ..initialized = true;
  }
}
