part of 'theming.dart';

class Themer extends StatelessWidget {

  Themer({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Theming state = store.get();
      return AnimatedTheme(
        data: state.data,
        child: this.child,
      );
    },
  );
}
