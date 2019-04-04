import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter/scheduler.dart';

import 'base.dart';
import 'auth.dart';
import 'browse.dart';
import 'route.dart';

class AppModelSideEffects with CacheScopeMixin, 
                               IOScopeMixin,
                               RedditScopeMixin,
                               RunnerScopeMixin,
                               RedditMixin {

  const AppModelSideEffects();

  @visibleForTesting
  AuthModel createAuthModelWithToken(
    Completer<RefreshToken> init,
    AuthCallback onAuthUpdated,
    RefreshToken token
  ) {
    // ignore: invalid_use_of_visible_for_testing_member
    return AuthModel.withToken(init, onAuthUpdated, token);
  }

  AuthModel createAuthModel(Completer<RefreshToken> init, AuthCallback onAuthUpdated) {
    return AuthModel(init, onAuthUpdated);
  }

  BrowseModel createBrowseModel(bool isSignedIn) => BrowseModel(isSignedIn);

  void setCurrentToken(RefreshToken token) {
    setInteractor(RedditInteractor(client: getClient(), refreshToken: token));
  }

  Future<void> initDependencies(String clientId, String redirect) async {
    setClient(RedditClient(clientId, redirect));
    await initCache();
    await initIO();
    await initRunner();
  }
}

class AppModel extends Model {

  @visibleForTesting
  AppModel.withToken(
    String clientId,
    String redirect,
    RefreshToken token, [
    this._sideEffects = const AppModelSideEffects()
  ]) {
    _isSettingUp = true;
    _sideEffects.initDependencies(clientId, redirect).then((_) {
      _auth = _sideEffects.createAuthModelWithToken(
        Completer<RefreshToken>()..future.then((RefreshToken token) {
          _isSettingUp = false;
          _isSignedIn = true;
          _sideEffects.setCurrentToken(token);
          _browse = _sideEffects.createBrowseModel(_isSignedIn);
          notifyListeners();
        }),
        _updateToken,
        token
      );
    });
  }

  AppModel(
    String clientId,
    String redirect, [
    this._sideEffects = const AppModelSideEffects()
  ]) {
    _isSettingUp = true;
    _sideEffects.initDependencies(clientId, redirect).then((_) {
      _auth = _sideEffects.createAuthModel(
        Completer<RefreshToken>()..future.then((RefreshToken token) {
          _isSettingUp = false;
          _isSignedIn = token != null;
          _sideEffects.setCurrentToken(null);
          _browse = _sideEffects.createBrowseModel(_isSignedIn);
          notifyListeners();
        }),
        _updateToken
      );
    });
  }

  bool get isSettingUp => _isSettingUp;
  bool _isSettingUp;

  bool get isSignedIn => _isSignedIn;
  bool _isSignedIn;

  AuthModel get auth => _auth;
  AuthModel _auth;

  BrowseModel get browse => _browse;
  BrowseModel _browse;

  final AppModelSideEffects _sideEffects;

  /// Called whenever the [auth] model changes the currently authenticated user.
  void _updateToken(RefreshToken token, bool userChanged) {
  }
}

class App extends StatelessWidget {

  App({ Key key, @required this.model })
    : super(key: key);

  final AppModel model;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Material(
        child: ValueBuilder(
          listenable: model,
          valueGetter: () => model.isSettingUp,
          builder: (BuildContext _, bool isSettingUp, Widget __) {
            return isSettingUp
              ? Center(child: CircularProgressIndicator())
              : _AppScaffold(model: model);
          },
        )
      ),
    );
  }
}

class _AppScaffold extends View<AppModel> {

  _AppScaffold({ Key key, @required AppModel model })
    : super(key: key, model: model);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ViewState<AppModel, _AppScaffold> with NavigatorObserver, ModelPageRouteObserverMixin {
  
  static const String _browseRouteName = 'browse';
  static const String _appMenuRouteName = 'app_menu';

  @override
  bool get rebuildOnChanges => true;

  final GlobalKey<NavigatorState> _browseNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<BottomSheetState> _bottomSheetKey = GlobalKey<BottomSheetState>();
  final GlobalKey<NavigatorState> _menuNavigatorKey = GlobalKey<NavigatorState>();

  String _currentRouteStack = _browseRouteName;

  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
    _maybeUpdateBottomSheetHandle(route);
  }

  void _maybeUpdateBottomSheetHandle(Route route) {
    if (route is ModelPageRoute) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _bottomSheetKey.currentState.handle = route.buildBottomHandle(context);
      });
    }
  }

  @override
  void didPop(Route route, Route previousRoute) {
    super.didPop(route, previousRoute);
    _maybeUpdateBottomSheetHandle(previousRoute);
  }

  Future<bool> _handleWillPop() async {
    final NavigatorState menuNavigator = _menuNavigatorKey.currentState;
    if (menuNavigator.canPop()) {
      menuNavigator.pop();
      return false;
    }

    final BottomSheetState bottomSheet = _bottomSheetKey.currentState;
    if (bottomSheet.status == AnimationStatus.forward || bottomSheet.status == AnimationStatus.completed) { 
      bottomSheet.collapse();
      return false;
    }

    final NavigatorState browseNavigator = _browseNavigatorKey.currentState;
    if (browseNavigator.canPop()) {
      browseNavigator.pop();
      return false;
    }

    final bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Really Exit'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No'),
            )
          ],
        );
      }
    );

    return result ?? false;
  }

  void _handleBottomSheetStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      final NavigatorState navigator = _menuNavigatorKey.currentState;
      while (navigator.canPop())
        navigator.pop();
    }
  }

  Route _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case _browseRouteName:
        return BrowsePageRoute(model: model.browse);
      case _appMenuRouteName:
        return FadeRoute(builder: (_) => _AppMenu(model: model));
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const EmptyBox()
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: _handleWillPop,
    child: Stack(
      children: <Widget>[
        Offstage(
          offstage: _currentRouteStack != _browseRouteName,
          child: Navigator(
            key: _browseNavigatorKey,
            initialRoute: _browseRouteName,
            onGenerateRoute: _buildRoute,
            observers: <NavigatorObserver>[ this ],
          ),
        ),
        BottomSheet(
          key: _bottomSheetKey,
          onStatusChanged: _handleBottomSheetStatusChange,
          body: Navigator(
            key: _menuNavigatorKey,
            initialRoute: _appMenuRouteName,
            onGenerateRoute: _buildRoute
          ),
        )
      ],
    )
  );
}

class _AppMenu extends StatelessWidget {

  _AppMenu({
    Key key,
    @required this.model
  }) : super(key: key);

  final AppModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 48.0,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SubheadText('Alien'),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => AuthMenu.show(context, model.auth),
                  icon: Icon(Icons.account_box),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings),
                )
              ],
            )
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListItem(
                  onTap: () {},
                  icon: Icon(Icons.explore),
                  title: Text('Browse'),
                ),
                ListItem(
                  onTap: () {},
                  icon: Icon(Icons.search),
                  title: Text('Search'),
                )
              ],
            )
          )
        ],
      )
    );
  }
}