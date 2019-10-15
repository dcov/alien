part of 'app.dart';

class AppInit extends Event {

  const AppInit();

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
