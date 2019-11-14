part of 'routing.dart';

typedef EntryFactory = ScaffoldEntry Function(RoutingTarget target);

typedef EventFactory = Event Function(RoutingTarget target);

abstract class RouterEntry extends ScaffoldEntry {
  RoutingTarget get target;
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

  static void push(BuildContext context, RoutingTarget target) {
    final RouterKey controller = RouterKey.of(context);
    final RouterState router = controller.routerKey.currentState;
    assert(router != null);
    router.push(target);
    controller.onPush();
  }

  static void pop(BuildContext context, [RoutingTarget target]) {
    final RouterKey controller = RouterKey.of(context);
    final RouterState router = controller.routerKey.currentState;
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

typedef RouterEventDispatch = void Function(
  BuildContext context,
  Event event,
);

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

  CustomScaffoldState get _scaffold => _scaffoldKey.currentState;

  void push(RoutingTarget target) async {
    assert(target != null);
    final UnmodifiableListView<RouterEntry> entries = _scaffold.entries.cast<RouterEntry>();
    if (target == entries.last.target)
      return;

    // Check if [target] is already in [Routing.tree], if it's not we'll
    // push onto the scaffold stack, otherwise we'll do a replace.
    if (!widget.routing.tree.contains(target)) {
      widget.dispatch(context, widget.onGeneratePush(target));
      final RouterEntry entry = widget.onGenerateEntry(target);
      await _scaffold.push(entry);
    } else {
      await _replaceStack(
        from: target,
        includeFrom: true
      );
    }
  }

  void pop([RoutingTarget target]) async {
    target ??= widget.routing.current;
    final UnmodifiableListView<RouterEntry> entries = _scaffold.entries.cast<RouterEntry>();

    if (target == entries.last.target && target.depth > 0) {
      await _scaffold.pop();
    } else if (entries.any((entry) => entry.target == target)) {
      await _replaceStack(
        from: target,
        includeFrom: target.depth > 0 ? false : true
      );
    }

    widget.dispatch(context, widget.onGeneratePop(target));
  }

  Future<void> _replaceStack({
      @required RoutingTarget from,
      @required bool includeFrom
    }) {
    final List<RouterEntry> stack = <RouterEntry>[];
    
    if (includeFrom) {
      stack.add(widget.onGenerateEntry(from));
    }

    int index = widget.routing.tree.indexOf(from) - 1;
    int depth = from.depth;
    while (index >= 0 && depth > 0) {
      final RoutingTarget other = widget.routing.tree[index];
      if (other.depth < depth) {
        stack.insert(0, widget.onGenerateEntry(other));
        depth = other.depth;
      }
      index--;
    }

    return _scaffold.replace(stack).then((_) {});
  }

  GlobalKey<CustomScaffoldState> _scaffoldKey;

  // We cache the [CustomScaffold] so that it only rebuilds when it's internal
  // state changes i.e. when we mutate [CustomScaffoldState] directly.
  Widget _child;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<CustomScaffoldState>();
  }

  @override
  void reassemble() {
    super.reassemble();
    _scaffoldKey = GlobalKey<CustomScaffoldState>();
    _child = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_child == null) {
      _child = CustomScaffold(
        key: _scaffoldKey,
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

