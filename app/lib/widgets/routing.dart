import 'dart:collection';

import 'package:flutter/widgets.dart';

class RoutingEntry {

  RoutingEntry({
    @required this.depth,
    @required this.page,
  });

  final int depth;

  final Page page;

  RoutingEntry get parent => _parent;
  RoutingEntry _parent;

  UnmodifiableListView<RoutingEntry> get childEntries => UnmodifiableListView(_childEntries);
  final _childEntries = List<RoutingEntry>();
}

class _RoutingStateScope extends InheritedWidget {

  _RoutingStateScope({
    Key key,
    @required this.rootEntry,
    Widget child
  }) : super(key: key, child: child);

  final RoutingEntry rootEntry;

  @override
  bool updateShouldNotify(_RoutingStateScope oldWidget) => true;
}

typedef RoutingPageBuilder = Page Function(String name);

class Routing extends StatefulWidget {

  Routing({
    Key key,
    this.initialPageName = 'app',
    @required this.initialPageBuilder
  }) : super(key: key);

  final String initialPageName;

  final RoutingPageBuilder initialPageBuilder;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  /// The root entry in the tree
  RoutingEntry _rootEntry;

  /// This is the path of the child entries that make up the current navigation stack.
  List<int> _currentStack;

  RoutingEntry get _currentEntry {
    var entry = _rootEntry;
    for (final i in _currentStack) {
      entry = entry.childEntries[i];
    }
    return entry;
  }

  void push(String name, RoutingPageBuilder pageBuilder) {
    final currentEntry = _currentEntry;
    final childEntries = currentEntry._childEntries;
    final newRouteName = currentEntry.page.name + '/' + name;

    /// Check if [newRouteName] already exists. If it does [indexOf] will be set.
    int indexOf;
    for (var i = 0; i < childEntries.length; i++) {
      if (childEntries[i].page.name == newRouteName) {
        indexOf = i;
        break;
      }
    }

    if (indexOf != null) {
      _currentStack.add(indexOf);
    } else {
      // Build the new page
      final newPage = pageBuilder(newRouteName);
      assert(newPage.name == newRouteName);
      assert(newPage.key == ValueKey(newRouteName));

      // Insert the new entry just ahead of the current entry.
      final insertIndex = childEntries.length;
      childEntries.insert(
        insertIndex,
        RoutingEntry(
          page: newPage,
          depth: currentEntry.depth + 1));

      // Mark the new entry as the top of the stack.
      _currentStack.add(insertIndex);
    }

    setState(() {
      // Update the widget tree
    });
  }

  void pop([String name]) {
    if (name == null) {
      _popAt(_currentStack.last);
      _currentStack.removeLast();
    } else {
      final popIndex = _entries.indexWhere((entry) => entry.page.name == name);
      assert(popIndex != -1);
      _popAt(popIndex);

      /// Check if the entry we popped was in the current page stack.
      final stackPopIndex = _currentStack.indexOf(popIndex);
      if (stackPopIndex != -1) {
        _currentStack.removeRange(stackPopIndex, _currentStack.length);
      }
    }
    setState(() {
      // Update the widget tree
    });
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
    final initialPageName = '/' + widget.initialPageName;
    final initialPage = widget.initialPageBuilder(initialPageName);
    assert(initialPage.name == initialPageName);
    assert(initialPage.key == ValueKey(initialPageName));

    _entries = <RoutingEntry>[
      RoutingEntry(
        depth: 0,
        page: initialPage)
    ];

    // The current stack only contains the first entry
    _currentStack = <int>[0];
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Page> get _currentPages {
    final pages = <Page>[_rootEntry.page];
    var parent = _rootEntry;
    for (final i in _currentStack) {
      final child = parent.childEntries[i];
      pages.add(child.page);
      parent = child;
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return _RoutingStateScope(
      rootEntry: _rootEntry,
      child: Navigator(
        pages: _currentPages,
        onPopPage: _handlePopPage));
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

  void push(String name, RoutingPageBuilder pageBuilder) => _state.push(name, pageBuilder);

  void pop() => _state.pop();
}

abstract class EntryPage<T> extends Page<T> {

  EntryPage({
    @required String name,
    Object arguments
  }) : assert(name != null),
       super(key: ValueKey(name), name: name, arguments: arguments);
}

