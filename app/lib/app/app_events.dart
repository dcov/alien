part of 'app.dart';

class Init extends Event {

  const Init();

  @override
  dynamic update(App app) {
    app.initialized = false;
    return {
      UpdateTheme(theming: app.theming),
      const InitResources(),
    };
  }
}

class InitializedResources extends Event {

  const InitializedResources();

  @override
  dynamic update(App app) {
    app.initialized = true;
    return const InitTargets();
  }
}

