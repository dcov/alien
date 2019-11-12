part of 'app.dart';

class Init extends Event {

  const Init();

  @override
  Set<Message> update(App app) {
    app.initialized = false;
    return <Message>{
      UpdateTheme(theming: app.theming),
      const InitResources(),
    };
  }
}

class InitializedResources extends Event {

  const InitializedResources();

  @override
  Set<Event> update(App app) {
    app.initialized = true;
    return <Event>{
      const InitTargets()
    };
  }
}

