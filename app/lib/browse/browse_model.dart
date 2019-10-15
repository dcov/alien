part of 'browse.dart';

abstract class Browse extends RoutingTarget {

  factory Browse() {
    return _$Browse(
      subscriptions: Subscriptions(),
      depth: 0,
    );
  }

  Subscriptions get subscriptions;
}
