import 'package:flutter/cupertino.dart';

import '../ui/draggable_page_route.dart';
import '../ui/path_router.dart';

mixin _RoutingEntry {

  void initState(BuildContext context) { }

  void didChangeDependencies(BuildContext context) { }

  void dispose(BuildContext context) { }

  Widget build(BuildContext context);
}

class _EntryPage extends Page {

  _EntryPage({
    LocalKey? key,
    String? name,
    required this.entry,
  }) : super(key: key, name: name);

  final _RoutingEntry entry;

  @override
  Route createRoute(BuildContext context) {
    return DraggablePageRoute(
      settings: this,
      builder: entry.build);
  }
}

abstract class RootEntry with _RoutingEntry { }

abstract class RouteEntry extends PathRoute with _RoutingEntry { }

class Routing extends StatefulWidget {

  Routing({
    Key? key,
    required this.root
  }) : super(key: key);

  final RootEntry root;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingScope extends InheritedWidget {

  _RoutingScope({
    Key? key,
    required this.routing,
    required Widget child,
  }) : super(key: key, child: child);

  final _RoutingState routing;

  @override
  bool updateShouldNotify(_RoutingScope oldWidget) {
    return this.routing != oldWidget.routing;
  }
}

class _RoutingState extends State<Routing> {

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _router = PathRouter<RouteEntry>();
  var _stack = <Page>[];

  Map<String, PathNode<RouteEntry>> get nodes => _router.nodes;

  static Page _createPage(_RoutingEntry entry) {
    final name = entry is RouteEntry ? entry.path : 'root';
    return _EntryPage(
      key: ValueKey(name),
      name: name,
      entry: entry);
  }

  void goTo(
      String path, {
      PathRouteFactory<RouteEntry>? onCreateEntry,
      PathRouteVisitor<RouteEntry>? onUpdateEntry
    }) {
    final transition = _router.goTo(
      path,
      onCreateRoute: () {
        final entry = onCreateEntry!();
        entry.initState(context);
        entry.didChangeDependencies(context);
        return entry;
      },
      onUpdateRoute: onUpdateEntry);

    switch (transition) {
      case PathRouterGoToTransition.push:
        setState(() {
          _stack.add(_createPage(_router.stack.last));
        });
        break;
      case PathRouterGoToTransition.pop:
        setState(() {
          _stack.removeLast();
        });
        break;
      case PathRouterGoToTransition.replace:
        setState(() {
          _stack.replaceRange(1, _stack.length,
              _router.stack.map((RouteEntry entry) => _createPage(entry)));
        });
        break;
      case PathRouterGoToTransition.none:
        break;
    }
  }

  void remove(String path, { bool canRebuild = true }) {
    final transition = _router.remove(
        path,
        onRemovedRoute: (RouteEntry entry) {
          entry.dispose(context);
        });

    late bool rebuild;
    switch (transition) {
      case PathRouterRemoveTransition.pop:
        _stack.removeLast();
        rebuild = true;
        break;
      case PathRouterRemoveTransition.replace:
        _stack.replaceRange(1, _stack.length,
            _router.stack.map((RouteEntry entry) => _createPage(entry)));
        rebuild = true;
        break;
      case PathRouterRemoveTransition.none:
        rebuild = false;
        break;
    }

    if (rebuild && canRebuild) {
      setState(() { });
    }
  }

  void detach(String path, String newFragment) {
    final transition = _router.detach(path, newFragment);

    switch (transition) {
      case PathRouterDetachTransition.replace:
        setState(() {
          _stack.replaceRange(1, _stack.length,
              _router.stack.map((RouteEntry entry) => _createPage(entry)));
        });
        break;
      case PathRouterDetachTransition.none:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _stack.add(_createPage(widget.root));
  }

  @override
  void didUpdateWidget(Routing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.root != oldWidget.root) {
      setState(() {
        _stack.replaceRange(0, 1, <Page>[_createPage(widget.root)]); 
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNodeDependencies(_router.nodes.values);
  }

  void _updateNodeDependencies(Iterable<PathNode<RouteEntry>> nodes) {
    for (final node in nodes) {
      node.route.didChangeDependencies(context);
      _updateNodeDependencies(node.children.values);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _RoutingScope(
      routing: this,
      child: Navigator(
        key: _navigatorKey,
        onPopPage: (Route<dynamic> route, dynamic result) {
          final page = route.settings as _EntryPage;
          if (page.entry is RootEntry) {
            // TODO: Do something here to handle quitting the app
            return false;
          } else {
            assert(page.entry is RouteEntry);
            remove((page.entry as RouteEntry).path, canRebuild: false);
            return true;
          }
        },
        pages: _stack.toList()));
  }
}

extension RoutingExtension on BuildContext {

  _RoutingState get _routing {
    return this.dependOnInheritedWidgetOfExactType<_RoutingScope>()!.routing;
  }

  Map<String, PathNode<RouteEntry>> get nodes => _routing.nodes;

  void goTo(
      String path, {
      PathRouteFactory<RouteEntry>? onCreateEntry,
      PathRouteVisitor<RouteEntry>? onUpdateEntry 
    }) {
    _routing.goTo(path, onCreateEntry: onCreateEntry, onUpdateEntry: onUpdateEntry);
  }

  void remove(String path) {
    _routing.remove(path);
  }

  void detach(String path, String newFragment) {
    _routing.detach(path, newFragment);
  }
}
