import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../auth/auth.dart';
import '../defaults/defaults.dart';
import '../routing/routing.dart';
import '../subreddit/subreddit.dart';
import '../subscriptions/subscriptions.dart';

part 'targets_events.dart';
part 'targets_widgets.dart';

/// The different values that [mapTarget] can map to.
///
/// [tile] maps to a [Widget] that can be used in a list.
/// [entry] maps to a [RouterEntry].
/// [init] maps to an initializing [Event].
/// [dispoes] maps to a disposing [Event].
@visibleForTesting
enum MapTarget {
  tile,
  entry,
  init,
  dispose
}

/// Maps [target] to a value [map] based on its type; e.g. if [target] is a 
/// subtype of [Subscriptions], it'll return [InitSubscriptions],
/// [DisposeSubscriptions], [SubscriptionsEntry], or [SubscriptionsTile] based
/// on the value of [map].
///
/// Apart from its functionality, it also serves as a listing of all of the
/// [RoutingTarget]s in the app.
@visibleForTesting
dynamic mapTarget(RoutingTarget target, MapTarget map) {
  assert(target != null);
  assert(map != null);

  return target is Defaults ?
           map == MapTarget.tile ? DefaultsTile(defaults: target) :
           map == MapTarget.entry ? DefaultsEntry(defaults: target) :
           map == MapTarget.init ? InitDefaults(defaults: target) :
                                   DisposeDefaults(defaults: target) :
         target is Subreddit ?
           map == MapTarget.tile ? SubredditTile(subreddit: target) :
           map == MapTarget.entry ? SubredditEntry(subreddit: target) :
           map == MapTarget.init ? InitSubreddit(subreddit: target) :
                                   DisposeSubreddit(subreddit: target) :
         throw UnimplementedError('');
}

