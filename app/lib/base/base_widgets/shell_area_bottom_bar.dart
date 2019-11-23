part of '../base.dart';

class ShellAreaBottomBar extends StatelessWidget {

  ShellAreaBottomBar({
    Key key,
    @required this.animation,
    @required this.leading,
    @required this.primary,
    @required this.secondary
  }) : super(key: key);

  final Animation<double> animation;
  final Widget leading;
  final ShellAreaEntry primary;
  final ShellAreaEntry secondary;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kBarHeight,
      child: Material(
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
              child: Stack(
                children: <Widget>[
                  if (secondary != null)
                    ActionsRow(
                      animation: ReverseAnimation(animation),
                      children: secondary.buildBottomActions(context)
                    ),
                  ActionsRow(
                    animation: animation,
                    children: primary.buildBottomActions(context)
                  ),
                ]
              )
            )
          ]
        )
      )
    );
  }
}

