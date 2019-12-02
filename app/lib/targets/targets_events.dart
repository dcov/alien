part of 'targets.dart';

class InitTargets extends Event {

  const InitTargets();

  @override
  dynamic update(Model root) {
    assert(root is RootRouting);
    assert(root is RootAuth);

    final bool userIsSignedIn = (root as RootAuth).auth.currentUser != null;
    final List<Target> rootTargets = <Target>[
      Defaults(),
      if (userIsSignedIn)
        Subscriptions(),
    ];

    return <Event>{
      InitRouting(rootTargets: rootTargets),
      TargetsPush(
        target: userIsSignedIn
            ? rootTargets.singleWhere((t) => t is Subscriptions)
            : rootTargets.singleWhere((t) => t is Defaults)
      )
    };
  }
}

class TargetsPush extends Push {

  TargetsPush({ @required this.target })
    : assert(target != null);

  final Target target;

  @override
  dynamic update(RootRouting root) {
    // If the [target] is activated, return an event that initializes the [target].
    if (push(root.routing, target)) {
      return mapTarget(target, MapTarget.init);
    }

    return null;
  }
}

class TargetsPop extends Pop {

  TargetsPop({ @required this.target })
    : assert(target != null);

  final Target target;

  @override
  dynamic update(RootRouting root) {
    final Set<Target> removed = pop(root.routing, target);
    if (removed.isEmpty)
      return null;

    final Set<Event> disposeEvents = <Event>{};
    for (final Target target in removed) {
      final Event result = mapTarget(target, MapTarget.dispose);
      if (result != null)
        disposeEvents.add(result);
    }

    return disposeEvents;
  }
}

