part of 'app.dart';

class AlienApp extends StatelessWidget {

  AlienApp({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    stateBuilder: (BuildContext context, AppState state, EventDispatch dispatch) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.deepOrange,
        builder: (_, Widget child) {
          return Themer(
            theming: state.theming,
            child: child,
          );
        },
        home: state.initialized ? _Scaffolding() : _SplashScreen()
      );
    },
  );
}

class _SplashScreen extends StatelessWidget {

  _SplashScreen({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _Scaffolding extends StatefulWidget {

  _Scaffolding({ Key key }) : super(key: key);

  @override
  _ScaffoldingState createState() => _ScaffoldingState();
}

class _ScaffoldingState extends State<_Scaffolding> {

  final GlobalKey<SlidingLayoutState> _layoutKey = GlobalKey<SlidingLayoutState>();

  SlidingLayoutState get _layout => _layoutKey.currentState;

  void _open() => _layout.open();

  void _close() => _layout.close();

  @override
  Widget build(_) => NotificationListener<PushNotification>(
    onNotification: (_) {
      if (_layout.isOpen)
        _close();
      return true;
    },
    child: Scaffold(
      appBar: AppBar(title: Text('Alien')),
    )
  );
}
