part of 'routing.dart';

/// A [Router] specific [ShellAreaEntry]. 
abstract class RouterEntry extends ShellAreaEntry {
  Target get target;
}

/// The coordinator between [Routing] and [ShellArea].
/// 
/// All [Target]-related events (push, pop) should be 'routed' through the
/// [Router] so that the state within [Routing] and [ShellArea] are kept
/// in-sync.
abstract class Router {

  /// Dispatches a [Push] event with [target], and then creates a
  /// [target]-specific [RouterEntry] that is either 'pushed' onto [ShellArea],
  /// or 'swapped' in.
  ///
  /// Note: The order of events is important because some [target]-specific
  /// [RouterEntry]s may rely on state that needs to be initialized before it
  /// can be used.
  void push(Target target);

  /// 'pops', or 'swaps' out [target] from [ShellArea], depending on where
  /// [target] is located in the stack, and then dispatches a [Pop] event
  /// with [target].
  ///
  /// Note: The order of events is important because some [target]-specific
  /// [RouterEntry]s may be displaying state that is disposed of when a
  /// [Pop] event is dispatched. This way the state lives up until the
  /// [RouterEntry] is no longer being rendered, in which case it can be
  /// disposed of safely.
  void pop(Target target);
}

/// The default implementation of [Router]. The owner of the [Shell] instance
/// should mix this class into its [State].
mixin RouterMixin<W extends StatefulWidget> on State<W> implements Router {

  @protected
  Routing get routing;

  @protected
  ShellAreaState get body;

  @protected
  void didPush(Target target);

  @protected
  void didPop(Target target);

  @protected
  RouterEntry createEntry(Target target);

  @override
  void push(Target target) {
    assert(target != null);
    _synchronize(() async {
      final UnmodifiableListView<RouterEntry> entries = body.entries.cast<RouterEntry>();
      if (target == entries.last.target)
        return;

      /// Cache whether the [target] is already in the [routing.tree] before it
      /// gets pushed, we'll need it later.
      final bool wasInTree = routing.tree.contains(target);

      /// Send the push event to update the [routing] state.
      didPush(target);

      /// If [target] wasn't in the [routing.tree] before we sent the push event
      /// then we'll have [body] do a 'push' transition, otherwise we'll have it
      /// do a 'replace' transition.
      if (!wasInTree) {
        await body.push(createEntry(target));
      } else {
        await body.replace(_getStack(
          from: target,
          includeFrom: true
        ));
      }
    });
  }

  @override
  void pop([Target target]) {
    _synchronize(() async {
      target ??= routing.current;
      final UnmodifiableListView<RouterEntry> entries = body.entries.cast<RouterEntry>();

      /// If [target] is what's currently being shown, and it's not a root
      /// target i.e. has a depth of 0, then we'll have [body] do a 'pop'
      /// transition, otherwise we'll have it do a 'replace' transition.
      if (target == entries.last.target && target.depth > 0) {
        await body.pop();
      } else if (entries.any((entry) => entry.target == target)) {
        await body.replace(_getStack(
          from: target,
          includeFrom: target.depth > 0 ? false : true
        ));
      }

      /// [target] is no longer shown so it's safe to send a pop event.
      didPop(target);
    });
  }

  List<RouterEntry> _getStack({
    @required Target from,
    @required bool includeFrom
  }) {
    final List<RouterEntry> stack = <RouterEntry>[];
    
    if (includeFrom) {
      stack.add(createEntry(from));
    }

    int index = routing.tree.indexOf(from) - 1;
    int depth = from.depth;
    while (index >= 0 && depth > 0) {
      final Target other = routing.tree[index];
      if (other.depth < depth) {
        stack.insert(0, createEntry(other));
        depth = other.depth;
      }
      index--;
    }

    return stack;
  }

  Completer<void> _currentAction;
  bool _actionIsPending = false;

  /// Helper function that synchronizes functions, [fn], that mutate [body]
  /// so that mutations happen one afer another, instead of simultaneously.
  /// This is necessary so that, for example, a call to [push] only kicks off
  /// after a previous call to [pop] has finished animating, otherwise there'll
  /// be a 'jump' in the UI which can be confusing for the user.
  void _synchronize(Future<void> fn()) async {
    /// Check if an action is already in progress.
    if (_currentAction != null) {
      final Animation<double> animation = body.animation;
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
    await fn();
    _currentAction = null;
    action.complete();
  }

  @protected
  List<RouterEntry> get initialBodyEntries {
    return _getStack(
      from: routing.current,
      includeFrom: true
    );
  }

  @protected
  void handleBodyPop() => pop(routing.current);

  @protected
  Widget buildRouter({ Widget child }) {
    return _RouterScope(
      router: this,
      child: child
    );
  }
}

class _RouterScope extends InheritedWidget {

  _RouterScope({
    Key key,
    @required this.router,
    Widget child,
  }) : super(key: key, child: child);

  final Router router;

  @override
  bool updateShouldNotify(_RouterScope oldWidget) {
    return oldWidget.router != this.router;
  }
}

extension ScopedRouterExtensions on BuildContext {

  Router get router {
    final _RouterScope scope = this.inheritFromWidgetOfExactType(_RouterScope);
    assert(scope != null);
    return scope.router;
  }

  void push(Target target) => router.push(target);

  void pop(Target target) => router.pop(target);
}

