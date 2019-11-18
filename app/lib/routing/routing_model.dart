part of 'routing.dart';

@abs
abstract class RootRouting extends Model {
  Routing get routing;
}

@abs
abstract class Target implements Model {

  bool active;

  int depth;
}

abstract class Routing implements Model {

  factory Routing() => _$Routing(tree: const <Target>[]);

  Target current;

  List<Target> get tree;
}
