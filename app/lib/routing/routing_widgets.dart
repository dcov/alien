part of 'routing.dart';

typedef TargetEntryFactory = TargetEntry Function(Target target);

typedef TargetEventDispatch = void Function(Target target);

/// A [Target] specific [ShellAreaEntry]. 
abstract class TargetEntry extends ShellAreaEntry {
  Target get target;
}

class RoutingController implements ShellAreaController {

  RoutingController({
    @required this.routing,
    @required this.onGetArea,
    @required this.onGenerateEntry,
    @required this.onDispatchPush,
    @required this.onDispatchPop,
  }) : assert(routing != null),
       assert(onGetArea != null),
       assert(onGenerateEntry != null),
       assert(onDispatchPush != null),
       assert(onDispatchPop != null);

  final Routing routing;

  final ValueGetter<ShellAreaState> onGetArea;

  final TargetEntryFactory onGenerateEntry;
  
  final TargetEventDispatch onDispatchPush;

  final TargetEventDispatch onDispatchPop;

  List<TargetEntry> get initialBodyEntries {
    return _getStack(
      from: routing.current,
      includeFrom: true
    );
  }

  List<TargetEntry> _getStack({
    @required Target from,
    @required bool includeFrom
  }) {
    final List<TargetEntry> stack = <TargetEntry>[];
    
    if (includeFrom) {
      stack.add(onGenerateEntry(from));
    }

    int index = routing.tree.indexOf(from) - 1;
    int depth = from.depth;
    while (index >= 0 && depth > 0) {
      final Target other = routing.tree[index];
      if (other.depth < depth) {
        stack.insert(0, onGenerateEntry(other));
        depth = other.depth;
      }
      index--;
    }

    return stack;
  }

  @override
  void push(Target target) {
    assert(target != null);
    _synchronize((ShellAreaState area) async {
      final UnmodifiableListView<TargetEntry> entries = area.entries.cast<TargetEntry>();
      if (target == entries.last.target)
        return;

      /// Cache whether the [target] is already in the [routing.tree] before it
      /// gets pushed, we'll need it later.
      final bool wasInTree = routing.tree.contains(target);

      /// Send the push event to update the [routing] state.
      onDispatchPush(target);

      /// If [target] wasn't in the [routing.tree] before we sent the push event
      /// then we'll have [body] do a 'push' transition, otherwise we'll have it
      /// do a 'replace' transition.
      if (!wasInTree) {
        await area.push(onGenerateEntry(target));
      } else {
        await area.replace(_getStack(
          from: target,
          includeFrom: true
        ));
      }
    });
  }

  @override
  void pop([Target target]) {
    _synchronize((ShellAreaState area) async {
      final UnmodifiableListView<TargetEntry> entries = area.entries.cast<TargetEntry>();
      target ??= routing.current;

      /// If [target] is what's currently being shown, and it's not a root
      /// target i.e. has a depth of 0, then we'll have [body] do a 'pop'
      /// transition, otherwise we'll have it do a 'replace' transition.
      if (target == entries.last.target && target.depth > 0) {
        await area.pop();
      } else if (entries.any((entry) => entry.target == target)) {
        await area.replace(_getStack(
          from: target,
          includeFrom: target.depth > 0 ? false : true
        ));
      }

      /// [target] is no longer shown so it's safe to send a pop event.
      onDispatchPop(target);
    });
  }

  Completer<void> _currentAction;
  bool _actionIsPending = false;

  /// Helper function that synchronizes functions, [fn], that mutate the
  /// [ShellAreaState] that this [ShellAreaController] manages, so that
  /// mutations happen one afer another, instead of simultaneously. This is
  /// necessary so that, for example, a call to [push] only kicks off after a
  /// previous call to [pop] has finished animating, otherwise there'll be a
  /// 'jump' in the UI which can be confusing for the user.
  void _synchronize(Future<void> fn(ShellAreaState area)) async {
    final ShellAreaState area = onGetArea();

    /// Check if an action is already in progress.
    if (_currentAction != null) {
      final Animation<double> animation = area.animation;
      assert(animation.status != AnimationStatus.dismissed
          && animation.status != AnimationStatus.completed);

      /// An action is already in progress. If it's not at least halfway done, or
      /// another action is already pending, we won't continue with this action.
      if ((animation.status == AnimationStatus.forward
              && animation.value < 0.5) ||
          animation.value > 0.5 ||
          _actionIsPending) {
        return;
      }

      /// Wait for the current action to complete, and mark that we're doing so.
      _actionIsPending = true;
      await _currentAction.future;
      _actionIsPending = false;
    }

    /// Start the action and mark that an action is in progress.
    assert(_currentAction == null);
    final Completer<void> action = Completer<void>();
    _currentAction = action;
    await fn(area);
    _currentAction = null;
    action.complete();
  }
}

