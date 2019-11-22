part of 'app.dart';

/// The root widget in the tree.
///
/// It handles the one-off configuration of the application, and the initial
/// phase between when the [App] state has yet to be initialized, in which it
/// renders a graphic, and after it's been initialized, in which it renders the
/// initialized [App] state and doesn't rebuild anymore.
class Runner extends StatelessWidget {

  Runner({ Key key }) : super(key: key);

  @override
  Widget build(_) {
    /// Only allow portrait-up orientation. Certain [Widget]s will change this
    /// as needed, but the default is portrait-up.
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);

    return Connector(
      stateBuilder: (_, App app, __) {
        /// This check does two things: It checks whether the state has been
        /// initialized and returns [_Splash] if it hasn't, but more importantly
        /// it let's [Connector] know that the only value we depend on is
        /// the [app.initialized] value. This means we'll only rebuild once -
        /// when the [app.initialized] value is set to [true].
        if (!app.initialized)
          return _Splash();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (_, Widget child) {
            return Themer(
              theming: app.theming,
              child: child,
            );
          },
          home: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: _Main(app: app)
          )
        );
      }
    );
  }
}

class _Splash extends StatelessWidget {

  const _Splash({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class _Main extends StatefulWidget {

  _Main({
    Key key,
    this.app,
  }) : super(key: key);

  final App app;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<_Main> with _DrawerMixin, RouterMixin, TargetsMixin {

  final GlobalKey<ShellState> _shellKey = GlobalKey<ShellState>();

  ShellState get _shell => _shellKey.currentState;

  @override
  Auth get auth => widget.app.auth;

  @override
  Routing get routing => widget.app.routing;

  @override
  ShellAreaState get drawer => _shell.drawer;

  @override
  ShellAreaState get body => _shell.body;

  @override
  void push(Target target) {
    super.push(target);
    _shell.closeDrawer();
  }

  @override
  Widget build(_) {
    return buildRouter(
      child: Shell(
        key: _shellKey,
        initialDrawerEntries: initialDrawerEntries,
        initialBodyEntries: initialBodyEntries,
        onDrawerClose: handleDrawerClose,
        onBodyPop: handleBodyPop,
      )
    );
  }
}

mixin _DrawerMixin<W extends StatefulWidget> on State<W> {

  @protected
  Auth get auth;

  @protected
  Routing get routing;

  @protected
  ShellAreaState get drawer;

  @protected
  Widget buildTile(BuildContext context, Target target);

  @protected
  List<ShellAreaEntry> get initialDrawerEntries {
    return <ShellAreaEntry>[
      _DrawerEntry(
        auth: auth,
        routing: routing,
        tileBuilder: buildTile,
      )
    ];
  }

  @protected
  void handleDrawerClose() {
    if (drawer.entries.length > 1)
      drawer.replace(initialDrawerEntries);
  }
}

class _DrawerEntry extends ShellAreaEntry {

  _DrawerEntry({
    @required this.auth,
    @required this.routing,
    @required this.tileBuilder,
  });

  final Auth auth;

  final Routing routing;

  final Widget Function(BuildContext, Target) tileBuilder;

  @override
  String get title => auth.currentUser?.name ?? 'Alien';

  @override
  List<Widget> buildTopActions(BuildContext context) {
    return <Widget>[
      AuthButton(auth: auth)
    ];
  }

  @override
  Widget buildBody(_) => Connector(
    builder: (BuildContext context, _) {
      return ListView.builder(
        itemCount: routing.tree.length,
        itemBuilder: (BuildContext context, int index) {
          return tileBuilder(context, routing.tree[index]);
        }
      );
    }
  );
}

