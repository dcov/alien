import 'package:flutter/widgets.dart';

abstract class Page extends PageRoute {

  Page({ RouteSettings? settings }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}

typedef PageFactory = Page Function(RouteSettings settings);

class PageNavigator extends StatefulWidget {

  PageNavigator({
    Key? key,
    required this.onGeneratePage,
  }) : super(key: key);

  final PageFactory onGeneratePage;

  @override
  _PageNavigatorState createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  late GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: widget.onGeneratePage);
  }
}
