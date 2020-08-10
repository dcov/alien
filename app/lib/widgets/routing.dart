import 'package:flutter/widgets.dart';

abstract class RoutingEntry extends Page {

  int _depth;
}

class Routing extends StatefulWidget {

  Routing({
    Key key,
    @required this.initialPage
  }) : super(key: key);

  final Page initialPage;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  List<Page> _pages;

  void push(Page page) {
  }

  void pop() {
  }

  void _handleNavigatorPagePop(Route route, _) {
    // TODO: implement
  }

  @override
  void initState() {
    super.initState();
    _pages = List<Page>();
  }

  @override
  void dispose() {
    super.dispose();
    _pages.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: _pages,
      onPopPage: _handleNavigatorPagePop);
  }
}

extension RoutingExtensions on BuildContext {

  _RoutingState get _state {
    final context = this;
    if (context is StatefulElement && context.state is _RoutingState) {
      return context.state;
    }
    return context.findAncestorStateOfType<_RoutingState>();
  }

  void push(Page page) => _state.push(page);
}

