part of 'routing.dart';

@abs
abstract class RootRouting extends Model {
  Routing get routing;
}

@abs
abstract class RoutingTarget implements Model {

  bool active;

  int depth;
}

abstract class Routing implements Model {

  factory Routing() => _$Routing(tree: const <RoutingTarget>[]);

  RoutingTarget current;

  List<RoutingTarget> get tree;
}
