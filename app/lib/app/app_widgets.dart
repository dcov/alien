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

class _MainState extends State<_Main> with ConnectionStateMixin<App, _Main>, AuthMixin, TargetsMixin {

  final GlobalKey<ShellState> _shellKey = GlobalKey<ShellState>();
  _MenuController _menuController;
  RoutingController _routingController;

  ShellState get _shell => _shellKey.currentState;

  @override
  void initState() {
    super.initState();
    _routingController = RoutingController(
      routing: widget.app.routing,
      onGetArea: () => _shell.body,
      onGenerateEntry: super.createEntry,
      onDispatchPush: super.handlePush,
      onDispatchPop: super.handlePop,
    );
    _menuController = _MenuController(
      auth: widget.app.auth,
      routing: widget.app.routing,
      onGetShell: () => _shell,
      onGetDrawer: () => _shell.drawer,
      onTargetPush: (Target t) {
        _shell.closeDrawer();
        _routingController.push(t);
      },
      onTargetPop: _routingController.pop,
      tileBuilder: super.buildTile,
    );
  }

  @override
  void didChangeUser() {
    /// Schedule our response for after this frame because we'll be
    /// dispatching an [Event].
    SchedulerBinding.instance.addPostFrameCallback((_) {
      /// Reset the [App] state.
      dispatch(ResetState());

      /// This is safe to call, i.e. it will never fail, because while changing
      /// user accounts, calls to [RoutingController.push], or
      /// [RoutingController.pop] are not possible.
      ///
      /// See [RoutingController.resync] for why this is important.
      _routingController.resync();

      /// Pop to the main menu.
      _menuController.popToRoot();
    });
  }

  @override
  Widget build(_) {
    super.build(_);
    return Shell(
      key: _shellKey,
      drawerController: _menuController,
      bodyController: _routingController,
      initialDrawerEntries: _menuController.initialEntries,
      initialBodyEntries: _routingController.initialEntries,
    );
  }
}

typedef _TargetHandler = void Function(Target target);

typedef _TileBuilder = Widget Function(BuildContext context, Target target);

class _MenuController extends ShellAreaController {

  _MenuController({
    @required this.auth,
    @required this.routing,
    @required this.onGetShell,
    @required this.onGetDrawer,
    @required this.onTargetPush,
    @required this.onTargetPop,
    @required this.tileBuilder
  }) : assert(auth != null),
       assert(routing != null),
       assert(onGetDrawer != null),
       assert(onTargetPush != null),
       assert(onTargetPop != null);

  final Auth auth;

  final Routing routing;

  final ValueGetter<ShellState> onGetShell;

  final ValueGetter<ShellAreaState> onGetDrawer;

  final _TargetHandler onTargetPush;

  final _TargetHandler onTargetPop;

  final _TileBuilder tileBuilder;

  List<ShellAreaEntry> get initialEntries {
    return <ShellAreaEntry>[
      _MainMenuEntry(
        auth: auth,
        routing: routing,
        tileBuilder: tileBuilder,
      )
    ];
  }

  void popToRoot() async {
    final ShellState shell = onGetShell();
    final ShellAreaState drawer = onGetDrawer();
    while(drawer.entries.length > 1) {
      await drawer.pop();
    }
    shell.shrinkDrawer();
  }

  @override
  void push(Object value) async {
    if (value is Target) {
      onTargetPush(value);
    } else {
      assert(value is ShellAreaEntry);
      final ShellState shell = onGetShell();
      final ShellAreaState drawer = onGetDrawer();
      if (drawer.entries.length == 1) {
        await shell.expandDrawer();
      }
      drawer.push(value);
    }
  }

  @override
  void pop([Object value]) async {
    if (value is Target) {
      onTargetPop(value);
    } else {
      assert(value == null || value is ShellAreaEntry);
      final ShellState shell = onGetShell();
      final ShellAreaState drawer = onGetDrawer();
      assert(drawer.entries.length > 1);
      await drawer.pop(value);
      if (drawer.entries.length == 1)
        shell.shrinkDrawer();
    }
  }
}

class _MainMenuEntry extends ShellAreaEntry {

  _MainMenuEntry({
    @required this.auth,
    @required this.routing,
    @required this.tileBuilder,
  });

  final Auth auth;

  final Routing routing;

  final _TileBuilder tileBuilder;

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
      return PaddedScrollView(
        slivers: <Widget>[
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, int index) {
              return tileBuilder(context, routing.tree[index]);
            },
            childCount: routing.tree.length
          ))
        ]
      );
    }
  );
}

