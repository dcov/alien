import 'package:flutter/widgets.dart';

class AnimatedOffstage extends ImplicitlyAnimatedWidget {

  AnimatedOffstage({
    Key? key,
    required this.offstage,
    required this.child,
  }) : super(
    key: key,
    duration: const Duration(milliseconds: 250));

  final bool offstage;

  final Widget child;

  @override
  _AnimatedOffstageState createState() => _AnimatedOffstageState();
}

class _AnimatedOffstageState extends ImplicitlyAnimatedWidgetState<AnimatedOffstage> {
  late Tween<double> _opacity;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _opacity = visitor(
      _opacity,
      widget.offstage ? 0.0 : 1.0,
      (dynamic value) => Tween<double>(begin: value)) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double value = _opacity.evaluate(animation);
        return Offstage(
          offstage: value == 0.0,
          child: Opacity(
            opacity: value,
            child: child));
      });
  }
}
