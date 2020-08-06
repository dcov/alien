import 'package:elmer/elmer.dart';

import '../models/auth.dart';
import '../models/browse.dart';
import '../models/defaults.dart';
import '../models/home.dart';
import '../models/subscriptions.dart';

import 'defaults.dart';
import 'subscriptions.dart';

part 'browse.msg.dart';

@action initBrowse(Model model) {
  assert(model is AuthOwner);
  assert(model is BrowseOwner);

  final Auth auth = (model as AuthOwner).auth;
  final BrowseOwner owner = model as BrowseOwner;

  /// If a user is signed in, we'll initialize the [Browse] model with a
  /// [Home] model, and [Subscriptions] model.
  if (auth.currentUser != null) {
    owner.browse = Browse(
      home: Home(),
      subscriptions: Subscriptions());

    return RefreshSubscriptions(
      subscriptions: owner.browse.subscriptions);
  } else {
    /// A user is not signed in, so we'll initialize the [Browse] model
    /// with a [Defaults] model.
    owner.browse = Browse(defaults: Defaults());

    return LoadDefaults(
      defaults: owner.browse.defaults);
  }
}

