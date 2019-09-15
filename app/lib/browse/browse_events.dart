part of 'browse.dart';

class PushBrowse extends TargetPush {

  PushBrowse({ @required this.browseKey });

  final ModelKey browseKey;

  @override
  Effect update(Store store) {
    final Browse browse = store.get(browseKey);
    if (push(store, browse)) {
      if (utils.userIsSignedIn(store)) {
        browse.subscriptions = Subscriptions();
        return RefreshSubscriptions(
          subscriptionsKey: browse.subscriptions.key).update(store);
      } else {
        browse.defaults = Defaults();
        return RefreshDefaults(
          defaultsKey: browse.defaults.key).update(store);
      }
    }
    return null;
  }
}

class PopBrowseTarget extends TargetPop {

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
