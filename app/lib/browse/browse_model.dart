part of 'browse.dart';

abstract class Browse implements RoutingTarget {

  factory Browse() => _$Browse(
    defaults: Defaults(),
  );

  Defaults defaults;

  Subscriptions subscriptions;
}
