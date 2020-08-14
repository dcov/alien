import 'package:flutter/widgets.dart';

abstract class EntryRoute<T> extends PageRoute<T> {

  EntryRoute({
    @required RouteSettings settings,
    bool fullscreenDialog = false
  }) : assert(settings != null),
       assert(settings is Page),
       super(settings: settings, fullscreenDialog: fullscreenDialog);


  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute nextRoute) => true;
}

class RoutingData {

  RoutingData(this.entryNames);

  final List<String> entryNames;
}

class _RoutingDataScope extends InheritedWidget {

  _RoutingDataScope({
    Key key,
    @required this.data,
    Widget child
  }) : super(key: key, child: child);

  final RoutingData data;

  @override
  bool updateShouldNotify(_RoutingDataScope oldWidget) {
    return oldWidget.data != data;
  }
}

class _RoutingEntry {

  _RoutingEntry({
    this.name,
    this.depth,
    this.page,
    this.routeBuilder
  });

  String name;

  int depth;

  Page page;

  RouteBuilder routeBuilder;
}

class Routing extends StatefulWidget {

  Routing({
    Key key,
    this.initialRouteName = 'app',
    @required this.initialRouteBuilder
  }) : super(key: key);

  final String initialRouteName;

  final RouteBuilder initialRouteBuilder;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  List<_RoutingEntry> _entries;

  List<int> _currentStack;

  void push(String name, RouteBuilder routeBuilder) {
    final currentIndex = _currentStack.last;
    final currentEntry = _entries[currentIndex];
    final newRouteName = currentEntry.page.name + '/' + name;

    /// Check if [newRouteName] already exists. If it does [indexOf] will be set.
    int indexOf;
    for (var i = currentIndex + 1; i < _entries.length; i++) {
      final entry = _entries[i];
      if (entry.depth <= currentEntry.depth) {
        /// We are past any child entries of [currentEntry].
        break;
      }

      if ((entry.depth == (currentEntry.depth + 1)) &&
          entry.page.name == newRouteName) {
        indexOf = i;
        break;
      }
    }

    if (indexOf != null) {
      setState(() {
        _currentStack.add(indexOf);
      });
    } else {
      setState(() {
        // Insert an the new entry just ahead of the current entry.
        _entries.insert(
          currentIndex + 1,
          _RoutingEntry(
            page: CustomBuilderPage(
              key: ValueKey(newRouteName),
              name: newRouteName,
              routeBuilder: routeBuilder),
            depth: currentEntry.depth + 1));

        // Mark the new entry as the top of the stack.
        _currentStack.add(currentIndex + 1);
      });
    }
  }

  void pop([String name]) {
    setState(() {
      final poppedIndex = _currentStack.removeLast();
      _entries.removeAt(poppedIndex);
    });
  }

  void detach([String name]) {
  }

  void _handlePopPage(Route route, dynamic result) {
    assert(route.settings == _entries[_currentStack.last].page);
    if (route.didPop(result)) {
      pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _entries = <_RoutingEntry>[
      _RoutingEntry(
        depth: 0,
        page: CustomBuilderPage(
          key: ValueKey('/'),
          name: '/',
          routeBuilder: widget.initialRouteBuilder),
        name: widget.initialRouteName,
        routeBuilder: widget.initialRouteBuilder)
    ];
    // The current stack only contains the first entry
    _currentStack = <int>[0];
  }

  @override
  void dispose() {
    super.dispose();
    _entries.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: _currentStack.map((int index) => _entries[index].page).toList(),
      onPopPage: _handlePopPage);
  }
}

extension RoutingContextExtensions on BuildContext {

  RoutingData get routingData {
    return dependOnInheritedWidgetOfExactType<_RoutingDataScope>().data;
  }

  _RoutingState get _state {
    final context = this;
    if (context is StatefulElement && context.state is _RoutingState) {
      return context.state;
    }
    return context.findAncestorStateOfType<_RoutingState>();
  }

  void push(String name, RouteBuilder routeBuilder) => _state.push(name, routeBuilder);

  void pop() => _state.pop();
}

