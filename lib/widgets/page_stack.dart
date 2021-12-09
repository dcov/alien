import 'dart:collection';

import 'package:flutter/widgets.dart';

abstract class PageStackEntry extends Page {

  PageStackEntry({
    required ValueKey<String> key,
    String? name
  }) : super(key: key, name: name);

  String get id => (key! as ValueKey<String>).value;

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
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: FadeTransition(
            opacity: ReverseAnimation(secondaryAnimation),
            child: build(context),
          ),
        );
      }
    );
  }
}

class PageStack extends StatefulWidget {

  PageStack({
    Key? key,
    required this.onCreateRoot,
    required this.onCreatePage,
    required this.onStackChanged,
  }) : super(key: key);

  final PageStackEntry Function(BuildContext context) onCreateRoot;

  final PageStackEntry Function(BuildContext context, String id, Object? args) onCreatePage;

  final void Function(List<PageStackEntry> stack) onStackChanged;

  static final rootId = 'root';

  @override
  PageStackState createState() => PageStackState();
}

class PageStackState extends State<PageStack> {

  PageStackEntry? _rootEntry;
  final _entries = <PageStackEntry>[];

  bool _rootIsTopOfStack = false;

  List<PageStackEntry> _buildStack() {
    if (_rootIsTopOfStack)
      return <PageStackEntry>[
        ..._entries,
        _rootEntry!,
      ];

    return <PageStackEntry>[
      _rootEntry!,
      ..._entries,
    ];
  }

  void push(String id, Object? args) {
    if (id == PageStack.rootId) {
      setState(() {
        _rootIsTopOfStack = true;
      });
    } else {
      int? index;
      for (var i = 0; i < _entries.length; i++) {
        if (_entries[i].id == id) {
          index = i;
          break;
        }
      }

      if (index == null) {
        final newEntry = widget.onCreatePage(context, id, args);
        assert(newEntry.id == id);
        newEntry.initState(context);
        setState(() {
          _entries.add(newEntry);
          _rootIsTopOfStack = false;
        });
      } else if (index == _entries.length - 1) {
        if (_rootIsTopOfStack) {
          setState(() {
            _rootIsTopOfStack = false;
          });
        }
      } else {
        setState(() {
          final entry = _entries.removeAt(index!);
          _entries.add(entry);
          _rootIsTopOfStack = false;
        });
      }
    }
    widget.onStackChanged(_buildStack());
  }

  void popRoot() {
    assert(_rootIsTopOfStack);
    setState(() {
      _rootIsTopOfStack = false;
    });
    widget.onStackChanged(_buildStack());
  }

  bool _handlePop(Route route, dynamic result) {
    if (route.didPop(result)) {
      final page = route.settings as PageStackEntry;
      if (page.id == PageStack.rootId) {
        setState(() {
          _rootIsTopOfStack = false;
        });
      } else {
        page.dispose(context);
        setState(() {
          final removed = _entries.remove(page);
          assert(removed);
        });
      }

      widget.onStackChanged(_buildStack());

      return true;
    }

    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rootEntry == null) {
      _rootEntry = widget.onCreateRoot(context);
      assert(_rootEntry!.id == PageStack.rootId);
      _rootEntry!.initState(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PageStackScope(
      state: this,
      child: Navigator(
        onPopPage: _handlePop,
        pages: _buildStack(),
      ),
    );
  }
}

class _PageStackScope extends InheritedWidget {

  _PageStackScope({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final PageStackState state;

  @override
  bool updateShouldNotify(_PageStackScope oldScope) {
    return this.state != oldScope.state;
  }
}

extension PageStackExtension on BuildContext {

  PageStackState get _state {
    return this.dependOnInheritedWidgetOfExactType<_PageStackScope>()!.state;
  }

  List<PageStackEntry> get pageStack => UnmodifiableListView(_state._entries);

  void push(String id, [Object? args]) {
    _state.push(id, args);
  }
}
