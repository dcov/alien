import 'package:elmer/elmer.dart';

import '../auth/auth_model.dart';
import '../defaults/defaults_events.dart';
import '../defaults/defaults_model.dart';
import '../home/home_model.dart';
import '../subscriptions/subscriptions_events.dart';
import '../subscriptions/subscriptions_model.dart';

import 'browse_model.dart';

class InitBrowse implements Event {

  const InitBrowse();

  @override
  dynamic update(Object model) {
    assert(model is RootAuth);
    assert(model is RootBrowse);

    final Auth auth = (model as RootAuth).auth;
    final RootBrowse root = model;

    /// If a user is signed in, we'll initialize the [Browse] model with a
    /// [Home] model, and [Subscriptions] model.
    if (auth.currentUser != null) {
      root.browse = Browse(
        home: Home(),
        subscriptions: Subscriptions());

      return RefreshSubscriptions(
        subscriptions: root.browse.subscriptions);
    } else {
      /// A user is not signed in, so we'll initialize the [Browse] model
      /// with a [Defaults] model.
      root.browse = Browse(defaults: Defaults());

      return LoadDefaults(
        defaults: root.browse.defaults);
    }
  }
}

