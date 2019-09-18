part of 'routing.dart';

/// Base class for an [Event] that represents a push to [Routing.targets].
/// Implementations should call [push] once they've acquired/instantiated the
/// [RoutingTarget].
abstract class PushTarget extends Event {

  const PushTarget();

  @protected
  bool push(Store store, RoutingTarget target) {
    final Routing routing = store.get();
    if (!routing.targets.contains(target)) {
      final int currentDepth = routing.currentTarget.depth;
      assert(currentDepth != null);
      final int currentIndex = routing.targets.indexOf(routing.currentTarget);
      assert(currentIndex != -1);
      target.depth = currentDepth + 1;
      routing.targets.insert(currentIndex + 1, target);
    }
    routing.currentTarget = target;
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
  void pop(Store store, RoutingTarget target) {
    assert(target != null);
    final Routing routing = store.get();
    assert(routing.targets.contains(target));

    final int index = routing.targets.indexOf(target);
    for (final int i = index + 1; i < routing.targets.length; ) {
      final RoutingTarget other = routing.targets[i];
      if (other.depth <= target.depth)
        break;

      other.depth = null;
      routing.targets.removeAt(i);
    }

    if (target.depth > 0) {
      routing.targets.removeAt(index);
      if (routing.currentTarget == target) {
        routing.currentTarget = routing.targets[index - 1];
      }
    } else if (routing.currentTarget == target) {
      routing.currentTarget = null;
    }
    target.active = false;
  }
}
