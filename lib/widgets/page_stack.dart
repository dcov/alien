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

class PageStackController extends ChangeNotifier {

  PageStackController({
    required this.onCreatePage,
    required this.onPageAdded,
    required this.onPageRemoved,
  });

  final PageStackEntry Function(Object arg) onCreatePage;

  final void Function(PageStackEntry page) onPageAdded;

  final void Function(PageStackEntry page) onPageRemoved;

  List<PageStackEntry> get stack => List.from(_stack);
  final _stack = <PageStackEntry>[];

  void push(BuildContext context, Object arg) {
    final newPage = onCreatePage(arg);

    int? index;
    for (var i = 0; i < _stack.length; i++) {
      if (_stack[i].id == newPage.id) {
        index = i;
        break;
      }
    }

    if (index == null) {
      newPage.initState(context);
      _stack.add(newPage);
      onPageAdded(newPage);
      notifyListeners();
    } else if (index != _stack.length - 1) {
      final page = _stack.removeAt(index);
      _stack.add(page);
      notifyListeners();
    }
  }

  void remove(BuildContext context, String id) {
    int? index;
    for (var i = 0; i < _stack.length; i++) {
      if (_stack[i].id == id) {
        index = i;
        break;
      }
    }

    assert(index != null);

    final page = _stack.removeAt(index!);
    page.dispose(context);
    onPageRemoved(page);
    notifyListeners();
  }
}

class PageStackView extends StatelessWidget {

  PageStackView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PageStackController controller;

  @override
  Widget build(BuildContext context) {
    return _PageStackScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          final stack = controller.stack;
          if (stack.isEmpty) {
            return const SizedBox();
          }

          return Navigator(
            onPopPage: (Route route, dynamic result) {
              if (route.didPop(result)) {
                final page = route.settings as PageStackEntry;
                controller.remove(context, page.id);
                return true;
              }

              return false;
            },
            pages: controller.stack,
          );
        },
      ),
    );
  }
}

class _PageStackScope extends InheritedWidget {

  _PageStackScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final PageStackController controller;

  @override
  bool updateShouldNotify(_PageStackScope oldWidget) {
    return this.controller != oldWidget.controller;
  }
}

extension PageStackExtension on BuildContext {

  PageStackController get _controller {
    return this.dependOnInheritedWidgetOfExactType<_PageStackScope>()!.controller;
  }

  void push(Object arg) {
    _controller.push(this, arg);
  }
}
