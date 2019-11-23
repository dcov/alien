part of '../base.dart';

class ActionsRow extends StatelessWidget {

  ActionsRow({
    Key key,
    @required this.animation,
    @required this.children,
  }) : super(key: key);

  final Animation<double> animation;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children
        )
      )
    );
  }
}

class IgnoreWhenAnimating extends AnimatedWidget {

  IgnoreWhenAnimating({
    Key key,
    @required AnimationController controller,
    @required this.until,
    @required this.child
  }) : super(
    key: key,
    listenable: _IsAnimatingNotifier(controller, until)
  );

  final double until;

  final Widget child;

  @override
  _IsAnimatingNotifier get listenable => super.listenable;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: listenable.value,
      child: child,
    );
  }
}

class _IsAnimatingNotifier extends ValueNotifier<bool> {

  _IsAnimatingNotifier(this.controller, this.until)
    : super(controller.isAnimating);

  final AnimationController controller;
  final double until;

  void _handleStatusChange(_) {
    value = controller.isAnimating || controller.value != until;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    controller.addStatusListener(_handleStatusChange);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    controller.removeStatusListener(_handleStatusChange);
  }
}

