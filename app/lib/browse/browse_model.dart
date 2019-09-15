part of 'browse.dart';

abstract class Browse extends RoutingTarget {

  factory Browse() => _$Browse(
    defaults: Defaults(),
  );

  Defaults defaults;

  Subscriptions subscriptions;
}
