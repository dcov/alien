part of 'routing.dart';

typedef EntryFactory = ShellEntry Function(Target target);

typedef EventFactory = Event Function(Target target);

typedef RouterEventDispatch = void Function(
  BuildContext context,
  Event event,
);

abstract class RouterEntry extends ShellEntry {
  Target get target;
}

class RouterKey extends InheritedWidget {

  RouterKey({
    Key key,
    @required this.routerKey,
    @required this.onPush,
    Widget child,
  }) : assert(routerKey != null),
       super(key: key, child: child);

  final GlobalKey<RouterState> routerKey;

  final VoidCallback onPush;

  static void push(BuildContext context, Target target) {
    final RouterKey key = RouterKey.of(context);
    final RouterState router = key.routerKey.currentState;
    assert(router != null);
    router.push(target);
    key.onPush();
  }

  static void pop(BuildContext context, [Target target]) {
    final RouterKey key = RouterKey.of(context);
    final RouterState router = key.routerKey.currentState;
    assert(router != null);
    router.pop(target);
  }

  static RouterKey of(BuildContext context) {
    final RouterKey controller = context.inheritFromWidgetOfExactType(RouterKey);
    assert(controller != null);
    return controller;
  }

  @override
  bool updateShouldNotify(RouterKey oldWidget) {
    return routerKey != oldWidget.routerKey;
  }
}

class Router extends StatefulWidget {

  Router({
    Key key,
    @required this.routing,
    @required this.onGenerateEntry,
    @required this.onGeneratePush,
    @required this.onGeneratePop,
    this.dispatch = LoopScope.dispatch,
  }) : super(key: key);

  final Routing routing;

  final EntryFactory onGenerateEntry;

  final EventFactory onGeneratePush;

  final EventFactory onGeneratePop;

  final RouterEventDispatch dispatch;

  @override
  RouterState createState() => RouterState();
}

class RouterState extends State<Router> {

  GlobalKey<ShellState> _shellKey;
  Completer<void> _currentAction;
  bool _actionIsPending = false;

  ShellState get _shell => _shellKey.currentState;

  void _synchronize(Future<void> fn()) async {
    // Check if an action is already in progress.
    if (_currentAction != null) {
      final Animation<double> animation = _shell.animation;
      assert(animation.status != AnimationStatus.dismissed
          && animation.status != AnimationStatus.completed);

      // An action is already in progress. If it's not at least halfway done, or
      // another action is already pending, we won't start this action.
      if ((animation.status == AnimationStatus.forward
              && animation.value < 0.5)
          || animation.value > 0.5
          || _actionIsPending) {
        return;
      }

      _actionIsPending = true;
      await _currentAction.future;
      _actionIsPending = false;
    }

    assert(_currentAction == null);
    final Completer<void> action = Completer<void>();
    _currentAction = action;
    await fn();
    _currentAction = null;
    action.complete();
  }

  Future<void> _replaceStack({
      @required Target from,
      @required bool includeFrom
    }) {
    final List<RouterEntry> stack = <RouterEntry>[];
    
    if (includeFrom) {
      stack.add(widget.onGenerateEntry(from));
    }

    int index = widget.routing.tree.indexOf(from) - 1;
    int depth = from.depth;
    while (index >= 0 && depth > 0) {
      final Target other = widget.routing.tree[index];
      if (other.depth < depth) {
        stack.insert(0, widget.onGenerateEntry(other));
        depth = other.depth;
      }
      index--;
    }

    return _shell.replace(stack).then((_) {});
  }

  void push(Target target) {
    assert(target != null);
    _synchronize(() async {
      final UnmodifiableListView<RouterEntry> entries = _shell.entries.cast<RouterEntry>();
      if (target == entries.last.target)
        return;

      final bool wasInTree = widget.routing.tree.contains(target);
      widget.dispatch(context, widget.onGeneratePush(target));

      // Check if [target] is already in [Routing.tree], if it's not we'll
      // push onto the [_shell] stack, otherwise we'll do a replace.
      if (!wasInTree) {
        final RouterEntry entry = widget.onGenerateEntry(target);
        await _shell.push(entry);
      } else {
        await _replaceStack(
          from: target,
          includeFrom: true
        );
      }
    });
  }

  void pop([Target target]) {
    _synchronize(() async {
      target ??= widget.routing.current;
      final UnmodifiableListView<RouterEntry> entries = _shell.entries.cast<RouterEntry>();

      if (target == entries.last.target && target.depth > 0) {
        await _shell.pop();
      } else if (entries.any((entry) => entry.target == target)) {
        await _replaceStack(
          from: target,
          includeFrom: target.depth > 0 ? false : true
        );
      }

      widget.dispatch(context, widget.onGeneratePop(target));
    });
  }

  // We cache the [TargetScaffold] so that it only rebuilds when it's internal
  // state changes i.e. when we mutate [TargetScaffoldState] directly.
  Widget _child;

  @override
  void initState() {
    super.initState();
    _shellKey = GlobalKey<ShellState>();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Rebuild [TargetScaffold] after a hot reload.
    _shellKey = GlobalKey<ShellState>();
    _child = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_child == null) {
      _child = Shell(
        key: _shellKey,
        onPop: pop
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _replaceStack(from: widget.routing.current, includeFrom: true);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        // TODO: handle back presses correctly.
        return false;
      },
      child: _child,
    );
  }
}

