import 'package:flutter/material.dart' hide BottomSheet;

import 'base.dart';

abstract class RouteModel extends Model {

  void didPush() { }

  void didPop() {
  }
}

abstract class ModelPageRoute<T, M extends RouteModel> extends PageRoute<T> {

  ModelPageRoute({
    RouteSettings settings,
    bool fullscreenDialog = false,
    @required this.model
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final M model;

  @override
  final bool maintainState = true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is ModelPageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is ModelPageRoute;
  }

  Widget buildBottomHandle(BuildContext context);

  @protected
  Widget build(BuildContext context);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = build(context);
    assert(result != null);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

mixin ModelPageRouteObserverMixin implements NavigatorObserver { 

  @override
  void didPush(Route route, Route previousRoute) {
    if (route is ModelPageRoute) {
      route.model.didPush();
    }
  }

  @override
  void didPop(Route route, Route previousRoute) {
    if (route is ModelPageRoute) {
      route.model.didPop();
    }
  }
}