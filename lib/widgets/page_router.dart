import 'package:flutter/material.dart';

import 'change_notifier_controller.dart';

class _PageEntryState {
  bool initialized = false;
}

abstract class PageEntry extends Page {

  PageEntry({
    LocalKey? key,
    String? name,
  }) : super(key: key, name: name);

  final _PageEntryState _state = _PageEntryState();

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
    required this.stack,
    required this.stackNotifier,
  }) : super(key: key);

  /// The page stack that [PageRouter] manages and displays.
  final List<PageEntry> stack;

  final ChangeNotifierController stackNotifier;

  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {

  final _navigatorKey = GlobalKey<NavigatorState>();

  void _initEntry(PageEntry entry) {
    assert(!entry._state.initialized);
    entry.initState(context);
    entry._state.initialized = true;
  }

  void _push(PageEntry entry) {
    _initEntry(entry);
    setState(() {
      widget.stack.add(entry);
    });
    widget.stackNotifier.notify();
  }

  bool _handlePop(Route route, dynamic result) {
    if (route.didPop(result)) {
      final page = route.settings as PageEntry;
      page.dispose(context);
      widget.stack.remove(page);
      widget.stackNotifier.notify();
      return true;
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.stack.length == 1 && !widget.stack.first._state.initialized) {
      _initEntry(widget.stack.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PageRouterScope(
      state: this,
      child: Navigator(
        key: _navigatorKey,
        onPopPage: _handlePop,
        pages: widget.stack.toList(),
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
