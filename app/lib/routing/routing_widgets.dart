part of 'routing.dart';

typedef TargetFactory = TargetRoute Function(RoutingTarget target);

typedef PopEventFactory = Event Function(RoutingTarget target);

typedef RouterBuilder = Widget Function(
  BuildContext context,
  Routing routing,
  Widget child
);

enum TargetTransition {
  push,
  pop,
  none,
}

abstract class TargetRoute<T> extends PageRoute<T> {

  TargetRoute({
    @required this.target,
    RouteSettings settings,
  }) : super(
         settings: settings,
         fullscreenDialog: false,
       );

  final RoutingTarget target;

  TargetTransition transition;
}

class Router extends StatefulWidget {

  Router({
    Key key,
    @required this.routing,
    @required this.onGenerateRoute,
    @required this.onGeneratePopEvent,
    @required this.builder,
  }) : super(key: key);

  final Routing routing;

  final TargetFactory onGenerateRoute;

  final PopEventFactory onGeneratePopEvent;

  final RouterBuilder builder;

  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends State<Router> with ConnectionStateMixin {

  @override
  void capture(StateSetter setState) {
  }

  @override
  Widget build(BuildContext context) {
  }
}

class _OldRouterState extends State<Router> with ConnectionStateMixin, NavigatorObserver {

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<TargetRoute> _history = <TargetRoute>[];
  final HeroController _heroController = HeroController(
    createRectTween: (begin, end) => RectTween(begin: begin, end: end)
  );

  NavigatorState get _navigator => _navigatorKey.currentState;

  Routing _routing;

  @override
  void didPop(Route route, Route previousRoute) {
    if (route is TargetRoute) {
      if (_history.last == route) {
        _history.removeLast();
      }
      dispatch(widget.onGeneratePopEvent(route.target));
    }
  }

  void _update() {
    assert(_routing != null);
    final RoutingTarget newTarget = _routing.currentTarget;
    if (_history.isNotEmpty && (_history.last.target == newTarget))
      return;

    void clear({ int until, bool pop }) {
      while (_history.length > until) {
        final TargetRoute route = _history.removeLast();
        if (pop) {
          _navigator.pop();
        } else {
          _navigator.removeRoute(route);
        }
      }
    }

    if (newTarget == null) {
      clear(until: 0, pop: false);
      return;
    }

    /// Figure out what the [Navigator] stack should currently look like.
    final List<RoutingTarget> stack = <RoutingTarget>[newTarget];
    int index = _routing.targets.indexOf(newTarget);
    int depth = newTarget.depth;
    while (depth > 0) {
      final RoutingTarget t = _routing.targets[--index];
      if (t.depth < depth) {
        stack.insert(0, t);
        depth = t.depth;
      }
    }

    // Populates the history using the [stack] that was resolved above,
    // starting from index [from].
    void populate({ int from }) {
      for (final RoutingTarget t in stack.skip(from)) {
        final TargetRoute route = widget.onGenerateRoute(t);
        assert(route.target == t);
        _history.add(route);
        _navigator.push(route);
      }
    }

    // Check if the [Navigator] stack is empty, in which case we can just
    // populate it without diffing.
    if (_history.isEmpty) {
      populate(from: 0);
      return;
    }

    // Check if the difference between the stacks is only 1 which means that
    // it might be a push or pop change.
    if ((_history.length - stack.length).abs() == 1) {
      if (_history.length < stack.length) {
        if (stack[_history.length - 1] == _history.last.target) {
          populate(from: _history.length);
          return;
        }
      } else if (_history[stack.length - 1].target == stack.last) {
        clear(until: _history.length - 1, pop: !_routing.targets.contains(_history.last.target));
        return;
      }
    }

    if (_history.length > stack.length) {
      clear(until: stack.length, pop: false);
    }

    int removed = 0;
    for (int i = _history.length - 1; i >= 0; i--) {
      if (_history[i].target == stack[i])
        break;
      removed++;
    }

    final int diff = _history.length - removed;
    clear(until: diff, pop: false);
    populate(from: diff);
  }

  @override
  void capture(StateSetter setState) {
    setState(() {
      if (_navigator == null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _update();
        });
      } else {
        _update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(
      context,
      _routing,
      Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const SizedBox()
        ),
        observers: <NavigatorObserver>[
          _heroController,
          this
        ]
      )
    );
  }
}
