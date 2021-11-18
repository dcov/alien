import 'package:flutter/material.dart';

import 'clickable.dart';

class _PageEntryState {
  bool initialized = false;
  bool isFirstPage = true;
}

abstract class PageEntry extends Page {

  PageEntry({
    LocalKey? key,
    String? name,
  }) : super(key: key, name: name);

  final _PageEntryState _state = _PageEntryState();

  bool get isFirstPage => _state.isFirstPage;

  @protected
  void initState(BuildContext context) { }

  @protected
  void dispose(BuildContext context) { }

  @protected
  Widget build(BuildContext context);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: FadeTransition(
            opacity: ReverseAnimation(secondaryAnimation),
            child: Material(
              color: Theme.of(context).canvasColor,
              child: build(context),
            ),
          ),
        );
      },
    );
  }
}

class PageRouter extends StatefulWidget {

  PageRouter({
    Key? key,
    required this.onPushPage,
    required this.onPopPage,
    required this.pages,
  }) : super(key: key);

  final ValueChanged<PageEntry> onPushPage;

  final ValueChanged<PageEntry> onPopPage;

  final List<PageEntry> pages;

  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {

  final _navigatorKey = GlobalKey<NavigatorState>();

  void _initPage(PageEntry page) {
    assert(!page._state.initialized);
    page.initState(context);
    page._state.initialized = true;
  }

  void _push(PageEntry page) {
    _initPage(page);
    page._state.isFirstPage = false;
    widget.onPushPage(page);
  }

  bool _handlePop(Route route, dynamic result) {
    if (route.didPop(result)) {
      final page = route.settings as PageEntry;
      page.dispose(context);
      widget.onPopPage(page);
      return true;
    }
    return false;
  }

  void _maybeInitFirstPage() {
    final firstPage = widget.pages.first;
    firstPage._state.isFirstPage = true;
    if (!firstPage._state.initialized) {
      _initPage(firstPage);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeInitFirstPage();
  }

  @override
  void didUpdateWidget(PageRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeInitFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return _PageRouterScope(
      state: this,
      child: Navigator(
        key: _navigatorKey,
        onPopPage: _handlePop,
        pages: List.from(widget.pages),
      ),
    );
  }
}

class _PageRouterScope extends InheritedWidget {

  _PageRouterScope({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final _PageRouterState state;

  @override
  bool updateShouldNotify(_PageRouterScope oldScope) {
    return this.state != oldScope.state;
  }
}

extension PageRouterExtensions on BuildContext {

  _PageRouterState get _state {
    return this.dependOnInheritedWidgetOfExactType<_PageRouterScope>()!.state;
  }

  void push(PageEntry entry) {
    _state._push(entry);
  }
}

class PopPageButton extends StatelessWidget {

  PopPageButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onClick: () => Navigator.pop(context),
      child: SizedBox(
        width: 56.0,
        height: 56.0,
        child: Center(child: Icon(
          Icons.arrow_back_rounded,
          size: 24.0,
        )),
      ),
    );
  }
}
