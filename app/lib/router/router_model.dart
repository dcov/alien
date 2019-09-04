part of 'router.dart';

abstract class RouteState extends Model {
}

abstract class RouterState extends Model {

  List<RouteState> get routes;
}
