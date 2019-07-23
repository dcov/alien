import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter/scheduler.dart';

import 'base.dart';
import 'auth.dart';
import 'browse.dart';
import 'route.dart';
import 'search.dart';

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

  SearchModel createSearchModel() => SearchModel();

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
          _search = _sideEffects.createSearchModel();
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
          _search = _sideEffects.createSearchModel();
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

  SearchModel get search => _search;
  SearchModel _search;

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

class _AppScaffoldState extends ViewState<AppModel, _AppScaffold> with SingleTickerProviderStateMixin {

  static const GlobalValueKey<String, NavigatorState> _browseNavigatorKey =
    GlobalValueKey('browse');
  static const GlobalValueKey<String, NavigatorState> _searchNavigatorKey =
    GlobalValueKey('search');
  static const GlobalValueKey<String, BottomSheetState> _bottomSheetKey =
    GlobalValueKey('bottomSheet');
  static const GlobalValueKey<String, NavigatorState> _menuNavigatorKey =
    GlobalValueKey('menu');

  @override
  bool get rebuildOnChanges => true;

  GlobalValueKey<String, NavigatorState> _currentPageNavigatorKey;

  @override
  void initState() {
    super.initState();
    _currentPageNavigatorKey = _browseNavigatorKey;
  }

  Future<bool> _handleWillPop() async {
    final NavigatorState pageNavigator = _currentPageNavigatorKey.currentState;
    if (pageNavigator.canPop()) {
      pageNavigator.pop();
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
      final NavigatorState menuNavigator = _menuNavigatorKey.currentState;
      while (menuNavigator.canPop())
        menuNavigator.pop();
    }
  }

  void _maybeUpdateCurrentPageNavigatorKey(GlobalValueKey<String, NavigatorState> value) {
    if (_currentPageNavigatorKey != value) {
      setState(() {
        _currentPageNavigatorKey = value;
        _bottomSheetKey.currentState.collapse();
      });
    }
  }

  Route _buildRoute(RouteSettings settings) {
    final String routeName = settings.name;
    if (routeName == _browseNavigatorKey.value) {
      return BrowsePageRoute(model: model.browse);
    } else if (routeName == _searchNavigatorKey.value) {
      return SearchPageRoute(model: model.search);
    } else if (routeName == _menuNavigatorKey.value) {
      return FadeRoute(builder: (_) =>
        _AppMenu(
          onBrowse: () => _maybeUpdateCurrentPageNavigatorKey(_browseNavigatorKey),
          onSearch: () => _maybeUpdateCurrentPageNavigatorKey(_searchNavigatorKey),
          model: model,
        )
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const EmptyBox()
    );
  }

  Widget _buildPageNavigator(GlobalValueKey<String, NavigatorState> key) {
    return Offstage(
      offstage: key != _currentPageNavigatorKey,
      child: Navigator(
        key: key,
        initialRoute: key.value,
        onGenerateRoute: _buildRoute,
        observers: [ ModelPageRouteObserver() ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: _handleWillPop,
    child: _buildPageNavigator(_browseNavigatorKey),
  );
}

class _AppMenu extends StatelessWidget {

  _AppMenu({
    Key key,
    @required this.onBrowse,
    @required this.onSearch,
    @required this.model
  }) : super(key: key);

  final VoidCallback onBrowse;
  final VoidCallback onSearch;
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
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                onTap: onBrowse,
                leading: Icon(Icons.explore),
                title: Text('Browse'),
              ),
              ListTile(
                onTap: onSearch,
                leading: Icon(Icons.search),
                title: Text('Search'),
              )
            ],
          )
        ],
      )
    );
  }
}