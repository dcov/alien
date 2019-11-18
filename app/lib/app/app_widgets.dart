part of 'app.dart';

/// The root widget in the tree. It handles the initial configuration of the
/// [Widget]s tree, and renders the [App] state.
class Runner extends StatelessWidget {

  Runner({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    stateBuilder: (_, App app, __) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (_, Widget child) {
          return Themer(
            theming: app.theming,
            child: child,
          );
        },
        home: app.initialized
          ? _MainScreen(app: app)
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

class _MainScreen extends StatefulWidget {

  _MainScreen({
    Key key,
    this.app,
  }) : super(key: key);

  final App app;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {

  final GlobalKey<RouterState> _routerKey = GlobalKey<RouterState>();

  @override
  Widget build(_) => RouterKey(
    routerKey: _routerKey,
    onPush: () { },
    child: ShellConfiguration(
      barHeight: 48.0,
      barElevation: 0.0,
      bottomLeading: Pressable(
        onPress: () { },
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
  );
}

class _MainDrawer extends StatelessWidget {

  _MainDrawer({
    Key key,
    @required this.app
  }) : super(key: key);

  final App app;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, _) {
      final List<Target> tree = app.routing.tree;
      return Material(
        child: Column(children: <Widget>[
          AuthBar(auth: app.auth),
          Expanded(child: ListView.builder(
            itemCount: tree.length,
            itemBuilder: (_, int index) => TargetsTile(target: tree[index])
          ))
        ])
      );
    }
  );
}

