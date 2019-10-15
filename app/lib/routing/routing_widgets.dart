part of 'routing.dart';

typedef EntryFactory = ScaffoldEntry Function(RoutingTarget target);

typedef RouterBuilder = Widget Function(
  BuildContext context,
  Routing routing,
  Widget child
);

abstract class RouterEntry extends ScaffoldEntry {
  RoutingTarget get target;
}

class Router extends StatefulWidget {

  Router({
    Key key,
    @required this.routing,
    @required this.onGenerateEntry,
    @required this.builder,
  }) : super(key: key);

  final Routing routing;

  final EntryFactory onGenerateEntry;

  final RouterBuilder builder;

  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends State<Router> with ConnectionStateMixin {

  final GlobalKey<CustomScaffoldState> _scaffoldKey = GlobalKey<CustomScaffoldState>();

  CustomScaffoldState get _scaffold => _scaffoldKey.currentState;

  void _update(RoutingTarget currentTarget, List<RoutingTarget> targets) {
    assert(currentTarget != null);
  }

  @override
  void capture(_) {
    final RoutingTarget currentTarget = widget.routing.currentTarget;
    final List<RoutingTarget> targets = widget.routing.targets;
    if (_scaffold == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _update(currentTarget, targets);
      });
    } else {
      _update(currentTarget, targets);
    }
  }

  // We cache the [CustomScaffold] so that it only rebuilds when it's internal
  // state changes i.e. when we mutate [CustomScaffoldState] directly.
  Widget _child;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _child ??= CustomScaffold(key: _scaffoldKey);
    return WillPopScope(
      onWillPop: () async {
        // Check if it's passed the halfway mark of 
        return false;
      },
      child: _child,
    );
  }
}
