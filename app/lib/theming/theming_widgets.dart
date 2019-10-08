part of 'theming.dart';

class Themer extends StatelessWidget {

  Themer({
    Key key,
    @required this.theming,
    @required this.child,
  }) : super(key: key);

  final Theming theming;

  final Widget child;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return AnimatedTheme(
        data: theming.data,
        child: this.child,
      );
    },
  );
}
