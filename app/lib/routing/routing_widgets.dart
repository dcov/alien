part of 'routing.dart';

enum RoutingTransition {
  push,
  pop,
  none
}

typedef RoutingBuilder = Widget Function(
  BuildContext context,
  List<RoutingTarget> targets,
  RoutingTarget oldTarget,
  RoutingTarget newTarget,
  RoutingTransition transition,
);

class Router extends StatefulWidget {

  Router({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final RoutingBuilder builder;

  @override
  _RouterState createState() => _RouterState();
}

class _RouterState extends State<Router> {

  RoutingTarget _oldTarget;
  int _oldIndex;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Routing routing = store.get();
      final RoutingTarget oldTarget = _oldTarget;
      final RoutingTarget newTarget = routing.currentTarget;
      int newIndex;
      RoutingTransition transition;

      if (oldTarget == null) {
        transition = RoutingTransition.none;
        if (newTarget != null) {
          newIndex = routing.targets.indexOf(newTarget);
        }
      } else if (newTarget == null) {
        transition = RoutingTransition.pop;
        newIndex = null;
      } else {
        newIndex = routing.targets.indexOf(newTarget);
        if (oldTarget == newTarget) {
          transition = RoutingTransition.none;
        } else {
          if ((oldTarget.depth - newTarget.depth).abs() != 1
              || (_oldIndex - newIndex).abs() != 1) {
            transition = RoutingTransition.none;
          } else if (oldTarget.depth < newTarget.depth) {
            transition = _oldIndex < newIndex
                ? RoutingTransition.push : RoutingTransition.none;
          } else {
            transition = newIndex < _oldIndex
                ? RoutingTransition.pop : RoutingTransition.none;
          }
        }
      }

      _oldTarget = newTarget;
      _oldIndex = newIndex;

      return widget.builder(
        context,
        routing.targets,
        oldTarget,
        newTarget,
        transition
      );
    },
  );
}

class PushNotification extends Notification {

  const PushNotification();

  static void notify(BuildContext context) {
    const PushNotification().dispatch(context);
  }
}
