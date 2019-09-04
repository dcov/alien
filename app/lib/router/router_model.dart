part of 'router.dart';

abstract class RouteState extends Model {
}

class RouterState extends Model {

  RouterState();

  ModelList<RouteState> get routes => _routes;
  ModelList<RouteState> _routes;

  @override
  Iterable<ModelCollection> get collections sync* {
    yield routes;
    yield* super.collections;
  }
}
