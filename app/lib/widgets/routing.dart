import 'package:flutter/widgets.dart';

class RoutingEntry {

  RoutingEntry({
    @required this.depth,
    @required this.page,
  });

  final int depth;

  final Page page;
}

class RoutingData {

  RoutingData(this.entries);
  
  final List<Page> entries;
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

  List<RoutingEntry> _entries;
  List<int> _currentStack;

  void push(String name, RoutingPageBuilder pageBuilder) {
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
      _currentStack.add(indexOf);
    } else {
      // Build the new page
      final newPage = pageBuilder(newRouteName);
      assert(newPage.name == newRouteName);
      assert(newPage.key == ValueKey(newRouteName));

      // Insert the new entry just ahead of the current entry.
      _entries.insert(
        currentIndex + 1,
        RoutingEntry(
          page: newPage,
          depth: currentEntry.depth + 1));

      // Mark the new entry as the top of the stack.
      _currentStack.add(currentIndex + 1);
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

  void _popAt(int popIndex) {
    final poppedEntry = _entries.removeAt(popIndex);
    while (_entries[popIndex].depth > poppedEntry.depth) {
      _entries.removeAt(popIndex);
    }
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

