import 'package:elmer/elmer.dart';
import 'package:meta/meta.dart';

import '../auth/auth_events.dart';
import '../browse/browse_events.dart';
import '../theming/theming_events.dart';

import 'app_effects.dart';
import 'app_model.dart';

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

    return <Message>{
      InitAuth(
        users: users,
        signedInUser: signedInUser,
      ),
      InitBrowse(),
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
    return <Message>{
    };
  }
}

class UserChangedUpdate extends ProxyUpdate<UserChanged> {

  const UserChangedUpdate();

  @override
  dynamic update(App app, UserChanged _) {
    return <Message>{
      ResetState(),
    };
  }
}

