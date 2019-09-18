part of 'routing.dart';

@abs
abstract class RoutingTarget extends Model {

  bool active;

  int depth;
}

abstract class Routing extends Model {

  factory Routing() => _$Routing(targets: const <RoutingTarget>[]);

  RoutingTarget currentTarget;

  List<RoutingTarget> get targets;
}
