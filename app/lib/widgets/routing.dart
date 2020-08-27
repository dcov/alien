import 'package:flutter/widgets.dart';

class RoutingEntry {

  RoutingEntry({
    @required this.depth,
    @required this.page,
  });

  final int depth;

  final Page page;
}

class _RoutingData {

  _RoutingData(this.entries);

  final List<RoutingEntry> entries;
}

class _RoutingDataScope extends InheritedWidget {

  _RoutingDataScope({
    Key key,
    @required this.data,
    Widget child
  }) : super(key: key, child: child);

  final _RoutingData data;

  @override
  bool updateShouldNotify(_RoutingDataScope oldWidget) {
    return oldWidget.data != data;
  }
}

typedef RoutingPageBuilder = Page Function(String name);

class Routing extends StatefulWidget {

  Routing({
    Key key,
    @required this.initialPageName,
    @required this.initialPageBuilder
  }) : super(key: key);

  final String initialPageName;

  final RoutingPageBuilder initialPageBuilder;

  static String joinPageNames(List<String> names) {
    return names.join('/');
  }

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  List<RoutingEntry> _entries;
  List<int> _currentStack;
  _RoutingData _data;

  void push(String name, RoutingPageBuilder pageBuilder) {
    final currentIndex = _currentStack.last;
    final currentEntry = _entries[currentIndex];
    final newRouteName = Routing.joinPageNames([currentEntry.page.name, name]);

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
      _data = _RoutingData(_entries);
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
      _data = _RoutingData(_entries);
    });
  }

  void _popAt(int popIndex) {
    final poppedEntry = _entries.removeAt(popIndex);
    while (_entries[popIndex].depth > poppedEntry.depth) {
      _entries.removeAt(popIndex);
    }
  }

  bool _handlePopPage(Route route, dynamic result) {
    assert(route.settings == _entries[_currentStack.last].page);
    if (route.didPop(result)) {
      pop();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final initialPage = widget.initialPageBuilder(widget.initialPageName);
    assert(initialPage.name == widget.initialPageName);
    assert(initialPage.key == ValueKey(widget.initialPageName));

    _entries = <RoutingEntry>[
      RoutingEntry(
        depth: 0,
        page: initialPage)
    ];

    // The current stack only contains the first entry
    _currentStack = <int>[0];
    _data = _RoutingData(_entries);
  }

  @override
  void dispose() {
    super.dispose();
    _entries.clear();
  }

  @override
  Widget build(BuildContext context) {
    print(_entries.length);
    return _RoutingDataScope(
      data: _data,
      child: Navigator(
        pages: _currentStack.map((int index) => _entries[index].page).toList(),
        onPopPage: _handlePopPage));
  }
}

extension RoutingContextExtensions on BuildContext {

  List<RoutingEntry> get routingEntries {
    return dependOnInheritedWidgetOfExactType<_RoutingDataScope>().data.entries;
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

