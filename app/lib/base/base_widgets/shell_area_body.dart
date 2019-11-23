part of '../base.dart';

class ShellAreaBody extends StatelessWidget {

  ShellAreaBody({
    Key key,
    @required this.animation,
    @required this.isReplace,
    @required this.primary,
    @required this.secondary,
  }) : super(key: key);

  final Animation<double> animation;
  final bool isReplace;
  final ShellAreaEntry primary;
  final ShellAreaEntry secondary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (secondary != null)
          ValueListenableBuilder(
            valueListenable: animation,
            builder: (BuildContext context, double value, Widget child) {
              Widget result = Opacity(
                opacity: 1.0 - value,
                child: child,
              );

              if (!isReplace) {
                result = Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    widthFactor: 1.0 - (value / 2),
                    child: result,
                  ),
                );
              }

              return result;
            },
            child: secondary.buildBody(context),
          ),
        ValueListenableBuilder(
          valueListenable: animation,
          builder: (BuildContext context, double value, Widget child) {
            Widget result = Opacity(
              opacity: value,
              child: child,
            );

            if (!isReplace) {
              result = Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: value,
                  child: result,
                ),
              );
            }

            return result;
          },
          child: primary.buildBody(context),
        ),
      ],
    );
  }
}

