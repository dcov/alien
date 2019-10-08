part of 'app.dart';

class InitApp extends Event {

  const InitApp();

  @override
  Set<Message> update(AppState state) {
    state.initialized = false;
    return <Message>{
      UpdateTheme(theming: state.theming),
      const InitResources(),
    };
  }
}

class InitializedResources extends Event {

  const InitializedResources();

  void update(AppState state) {
    state.initialized = true;
  }
}
