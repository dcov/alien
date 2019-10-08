part of 'routing.dart';

@abs
abstract class RoutingTarget implements Model {

  bool active;

  int depth;
}

abstract class Routing implements Model {

  factory Routing() => _$Routing(targets: const <RoutingTarget>[]);

  RoutingTarget currentTarget;

  List<RoutingTarget> get targets;
}
