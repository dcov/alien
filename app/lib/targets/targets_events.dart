part of 'targets.dart';

class InitTargets extends Event {

  const InitTargets();

  @override
  Set<Event> update(Model root) {
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

class TargetsPush extends PushTarget {

  TargetsPush({ @required this.target })
    : assert(target != null);

  final Target target;

  @override
  Event update(RootRouting root) {
    // If the [target] is activated, return an event that initializes the [target].
    if (push(root.routing, target)) {
      return mapTarget(target, MapTarget.init);
    }

    return null;
  }
}

class TargetsPop extends PopTarget {

  TargetsPop({ @required this.target })
    : assert(target != null);

  final Target target;

  @override
  Set<Event> update(RootRouting root) {
    final Set<Target> removed = pop(root.routing, target);
    if (removed.isEmpty)
      return null;

    return removed.map((Target target) {
      return mapTarget(target, MapTarget.dispose) as Event;
    }).toSet();
  }
}

