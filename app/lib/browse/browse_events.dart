part of 'browse.dart';

class PushBrowse extends PushTarget {

  PushBrowse({ @required this.browseKey });

  final ModelKey browseKey;

  @override
  Event update(Store store) {
    final Browse browse = store.get(browseKey);
    assert(browse != null);
    if (push(store, browse)) {
      if (userIsSignedIn(store)) {
        browse.subscriptions = Subscriptions();
        return RefreshSubscriptions(subscriptionsKey: browse.subscriptions.key);
      } else {
        browse.defaults = Defaults();
        return LoadDefaults(defaultsKey: browse.defaults.key);
      }
    }
    return null;
  }
}

class PopBrowse extends PopTarget {

  PopBrowse({ @required this.browseKey });

  final ModelKey browseKey;

  @override
  void update(Store store) {
    final Browse browse = store.get(browseKey);
    assert(browse != null);
    pop(store, browse);
    browse..defaults = null
          ..subscriptions = null;
  }
}
