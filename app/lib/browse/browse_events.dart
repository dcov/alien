part of 'browse.dart';

class PushBrowse extends PushTarget {

  PushBrowse({ @required this.browseKey });

  final ModelKey browseKey;

  @override
  Event update(Store store) {
    final Browse browse = store.get(browseKey);
    if (push(store, browse)) {
      if (utils.userIsSignedIn(store)) {
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

class PopBrowseTarget extends PopTarget {

  PopBrowseTarget({ @required this.browseKey });

  final ModelKey browseKey;

  @override
  void update(Store store) {
    final Browse browse = store.get(browseKey);
    pop(store, browse);
    browse..defaults = null
          ..subscriptions = null;
  }
}
