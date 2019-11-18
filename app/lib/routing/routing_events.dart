part of 'routing.dart';

class InitRouting extends Event {

  InitRouting({ @required this.rootTargets })
    : assert(rootTargets != null),
      assert(rootTargets.isNotEmpty);

  final List<Target> rootTargets;

  @override
  void update(RootRouting root) {
    final Routing routing = root.routing;
    routing.tree
        ..clear()
        ..addAll(rootTargets)
        ..forEach((Target target) {
          target.depth = 0;
        });
  }
}

abstract class PushTarget extends Event {

  const PushTarget();

  @protected
  bool push(Routing routing, Target target) {
    if (!routing.tree.contains(target)) {
      final int currentDepth = routing.current.depth;
      assert(currentDepth != null);
      final int currentIndex = routing.tree.indexOf(routing.current);
      assert(currentIndex != -1);
      target.depth = currentDepth + 1;
      routing.tree.insert(currentIndex + 1, target);
    }

    routing.current = target;

    if (target.active != true) {
      target.active = true;
      return true;
    }

    return false;
  }
}

abstract class PopTarget extends Event {

  const PopTarget();

  @protected
  Set<Target> pop(Routing routing, Target target) {
    assert(target != null);
    assert(routing.tree.contains(target));

    final Set<Target> removed = <Target>{};

    final int index = routing.tree.indexOf(target);
    final int childIndex = index + 1;
    while (childIndex < routing.tree.length) {
      final Target other = routing.tree[childIndex];
      if (other.depth <= target.depth)
        break;

      other.depth = null;
      other.active = false;
      routing.tree.removeAt(childIndex);
      removed.add(other);
    }

    if (target.depth > 0) {
      target.depth = null;
      target.active = false;
      routing.tree.removeAt(index);
      removed.add(target);
    }

    if (!routing.tree.contains(routing.current)) {
      routing.current = routing.tree[index - 1];
    }

    return removed;
  }
}

