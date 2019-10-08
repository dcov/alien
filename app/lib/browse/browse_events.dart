part of 'browse.dart';

class PushBrowse extends PushTarget {

  PushBrowse({ @required this.browse });

  final Browse browse;

  @override
  Event update(AppState state) {
    assert(browse != null);
    if (push(state.routing, browse)) {
      if (state.auth.currentUser != null) {
        browse.subscriptions = Subscriptions();
        return RefreshSubscriptions(subscriptions: browse.subscriptions);
      } else {
        browse.defaults = Defaults();
        return LoadDefaults(defaults: browse.defaults);
      }
    }
    return null;
  }
}

class PopBrowse extends PopTarget {

  PopBrowse({ @required this.browse });

  final Browse browse;

  @override
  void update(AppState state) {
    pop(state.routing, browse);
    //browse..defaults = null
    //      ..subscriptions = null;
  }
}
