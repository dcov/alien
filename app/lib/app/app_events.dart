part of 'app.dart';

class InitApp extends Event {

  const InitApp();

  @override
  void update(Store store) {
    store.get<AppState>()
        ..initialized = true;

    store.get<Theming>()
        ..type = ThemeType.light
        ..data = ThemeData.light();

    store.get<Routing>()
        ..targets.add(Browse()..depth = 0);
  }
}
