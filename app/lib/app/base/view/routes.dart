import 'package:flutter/material.dart';

class FadeRoute<T> extends MaterialPageRoute<T> {

  FadeRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
         builder: builder,
         settings: settings,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog
       );

  @override
  bool get hasBarrier => false;

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    return previousRoute is FadeRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    return nextRoute is FadeRoute && !nextRoute.fullscreenDialog;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}