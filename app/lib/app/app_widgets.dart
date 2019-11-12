part of 'app.dart';

/// The root widget in the tree. It handles the initial configuration of the
/// [Widget]s tree, and renders the [App] state.
class Runner extends StatelessWidget {

  Runner({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    stateBuilder: (_, App app, __) {
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        builder: (_, Widget child) {
          return Themer(
            theming: app.theming,
            child: child,
          );
        },
        home: app.initialized
          ? _Scaffolding(app: app)
          : _SplashScreen()
      );
    },
  );
}

class _SplashScreen extends StatelessWidget {

  const _SplashScreen({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _Scaffolding extends StatefulWidget {

  _Scaffolding({
    Key key,
    this.app,
  }) : super(key: key);

  final App app;

  @override
  _ScaffoldingState createState() => _ScaffoldingState();
}

class _ScaffoldingState extends State<_Scaffolding> {

  final GlobalKey<SlidingLayoutState> _layoutKey = GlobalKey<SlidingLayoutState>();
  final GlobalKey<RouterState> _routerKey = GlobalKey<RouterState>();

  SlidingLayoutState get _layout => _layoutKey.currentState;

  @override
  Widget build(_) => RouterKey(
    routerKey: _routerKey,
    onPush: () {
      if (_layout.isOpen)
        _layout.close();
      return true;
    },
    child: SlidingLayout(
      key: _layoutKey,
      drawer: _Drawer(app: widget.app),
      child: CustomScaffoldConfiguration(
        barHeight: 48.0,
        barElevation: 0.0,
        bottomLeading: Pressable(
          onPress: () => _layout.open(),
          child: SizedBox(
            width: 48.0,
            height: 48.0,
            child: Icon(
              Icons.menu,
              size: 24.0
            ),
          )
        ),
        child: TargetsRouter(routing: widget.app.routing)
      )
    )
  );
}

class _Drawer extends StatelessWidget {

  _Drawer({
    Key key,
    @required this.app
  }) : super(key: key);

  final App app;

  @override
  Widget build(_) => Connector(
    builder: (_, __) {
      final List<RoutingTarget> tree = app.routing.tree;
      return Material(
        child: Column(children: <Widget>[
          AppBar(title: Text('Alien')),
          Expanded(child: ListView.builder(
            itemCount: tree.length,
            itemBuilder: (_, int index) => TargetsTile(target: tree[index])
          ))
        ])
      );
    }
  );
}

