part of 'targets.dart';

class TargetsRouter extends StatelessWidget {

  TargetsRouter({
    Key key,
    @required this.routing,
  }) : super(key: key);

  final Routing routing;

  static RouterEntry _generateEntry(RoutingTarget target) {
    return mapTarget(target, MapTarget.entry);
  }

  static Event _generatePush(RoutingTarget target) {
    return TargetsPush(target: target);
  }

  static Event _generatePop(RoutingTarget target) {
    return TargetsPop(target: target);
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      key: RouterKey.of(context).routerKey,
      routing: routing,
      onGenerateEntry: _generateEntry,
      onGeneratePush: _generatePush,
      onGeneratePop: _generatePop
    );
  }
}

class TargetsTile extends StatelessWidget {

  TargetsTile({
    Key key,
    @required this.target,
  }) : super(key: key);

  final RoutingTarget target;

  @override
  Widget build(BuildContext context) {
    return mapTarget(target, MapTarget.tile);
  }
}

