part of 'scaffolding.dart';

class _OpacityAnimator extends StatelessWidget {

  _OpacityAnimator({
    Key key,
    @required Animation<double> animation,
    @required this.child,
    @required this.ignore
  }) : this.animation = CurvedAnimation(
          curve: Interval(0.4, 1.0, curve: Curves.easeIn),
          parent: animation),
       super(key: key);

  final Animation<double> animation;

  final Widget child;
  
  final bool ignore;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: this.animation,
      child: this.child,
      builder: (_, double value, Widget child) {
        Widget result = Opacity(
            opacity: value,
            child: child,
        );

        if (ignore) {
          result = IgnorePointer(
            ignoring: value != 1.0,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

class _Overlap extends StatelessWidget {

  _Overlap({
    Key key,
    @required this.animation,
    @required this.expanded,
    @required this.collapsed
  }) : super(key: key);

  final Animation<double> animation;

  final Widget expanded;

  final Widget collapsed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _OpacityAnimator(
          animation: this.animation,
          child: expanded,
          ignore: false,
        ),
        _OpacityAnimator(
          animation: ReverseAnimation(this.animation),
          child: collapsed,
          ignore: true,
        )
      ],
    );
  }
}
