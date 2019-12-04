part of 'app.dart';

class Init extends Event {

  const Init();

  @override
  dynamic update(_) => InitResources();
}

class InitResourcesSuccess extends Event {

  const InitResourcesSuccess({
    @required this.users,
    @required this.signedInUser,
  });

  final Map<String, String> users;

  final String signedInUser;

  @override
  dynamic update(App app) {
    app.initialized = true;
    return {
      InitAuth(
        users: users,
        signedInUser: signedInUser,
      ),
      UpdateTheme(theming: app.theming),
      ResetState()
    };
  }
}

class InitResourcesFail extends Event {

  const InitResourcesFail();

  /// TODO: Implement
  @override
  dynamic update(_) {
  }
}

class ResetState extends Event {

  const ResetState();

  @override
  dynamic update(App app) {
    return {
      InitTargets()
    };
  }
}

class UserChangedUpdate extends ProxyUpdate<UserChanged> {

  const UserChangedUpdate();

  @override
  dynamic update(App app, UserChanged _) {
    return <Message>{
      ResetState(),
      RenderUserChange(app: app),
    };
  }
}

