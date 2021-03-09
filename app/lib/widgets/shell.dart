import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/manual_value_notifier.dart';
import '../utils/path_router.dart';
import '../widgets/ignored_decoration.dart';
import '../widgets/ltr_drag_detector.dart';
import '../widgets/pressable.dart';
import '../widgets/rrect_top_border.dart';
import '../widgets/sheet_with_handle.dart';
import '../widgets/toolbar.dart';
import '../widgets/widget_extensions.dart';

const kExpandedHandleHeight = 40.0;
const kCollapsedHandleHeight = 48.0;

Widget _buildHandleWithDecoration(BuildContext context, Widget child, { required bool bottomBorder }) {
  return IgnoredDecoration(
    decoration: BoxDecoration(
      color: Theme.of(context).canvasColor,
      border: !bottomBorder
        ? null
        : Border(
            bottom: BorderSide(
              width: 0.0,
              color: Colors.grey))),
    child: child);
}

mixin _ShellChild {

  /// Called once by Shell to initialize any state that can be initialized through the BuildContext
  /// of Shell itself.
  void initState(BuildContext context) { }

  void didChangeDependencies(BuildContext context) { }

  /// Called once by Shell dispose of any state that can be disposed through the BuildContext of
  /// Shell itself.
  void dispose(BuildContext context) { }
}

class RouteComponents {

  RouteComponents({
    this.titleDecoration,
    this.titleMiddle,
    this.titleTrailing,
    this.contentHandle,
    required this.contentBody,
    this.optionsHandle,
    this.optionsBody,
    this.drawer
  });

  final BoxDecoration? titleDecoration;

  final Widget? titleMiddle;

  final Widget? titleTrailing;

  final Widget? contentHandle;

  final Widget contentBody;

  final Widget? optionsHandle;

  final Widget? optionsBody;

  final Widget? drawer;
}

abstract class ShellRoute extends PathRoute with _ShellChild {

  RouteComponents build(BuildContext context);
}

class RootComponents {

  RootComponents({
    required this.layer,
    required this.handle,
    required this.drawer
  });

  final Widget layer;

  final Widget handle;

  final Widget drawer;
}

abstract class ShellRoot with _ShellChild {

  bool _initialized = false;

  RootComponents build(
      BuildContext context,
      ValueListenable<Map<String, PathNode<ShellRoute>>> nodes,
      ValueListenable<List<ShellRoute>> stack);
}

class Shell extends StatefulWidget {

  Shell({
    Key? key,
    required this.root,
  }) : super(key: key);

  final ShellRoot root;

  @override
  _ShellState createState() => _ShellState();
}

class _ShellScope extends InheritedWidget {

  _ShellScope({
    Key? key,
    required this.state,
    required Widget child
  }) : super(key: key, child: child);

  final _ShellState state;

  @override
  bool updateShouldNotify(_ShellScope oldWidget) {
    return this.state != oldWidget.state;
  }
}

extension ShellExtension on BuildContext {

  _ShellState get _state => this.dependOnInheritedWidgetOfExactType<_ShellScope>()!.state;

  void goTo(
      String fullPath, {
      PathRouteFactory<ShellRoute>? onCreateRoute,
      PathRouteVisitor<ShellRoute>? onUpdateRoute
    }) {
    _state.goTo(
        fullPath,
        onCreateRoute: onCreateRoute,
        onUpdateRoute: onUpdateRoute);
  }

  void remove(String path) {
    _state.remove(path);
  }

  void detach(String path, String newFragment) {
    _state.detach(path, newFragment);
  }
}

class _ShellState extends State<Shell> {

  final _layersKey = GlobalKey<_LayersState>();
  final _router = PathRouter<ShellRoute>();
  late final _nodes = ManualValueNotifier<Map<String, PathNode<ShellRoute>>>(_router.nodes);
  late final _stack = ManualValueNotifier<List<ShellRoute>>(_router.stack);

  void goTo(
      String path, {
      PathRouteFactory<ShellRoute>? onCreateRoute,
      PathRouteVisitor<ShellRoute>? onUpdateRoute
    }) {
    final transition = _router.goTo(
      path,
      onCreateRoute: () {
        assert(onCreateRoute != null);
        final route = onCreateRoute!();
        route.initState(context);
        route.didChangeDependencies(context);
        return route;
      },
      onUpdateRoute: onUpdateRoute);

    _nodes.notify();
    switch (transition) {
      case PathRouterGoToTransition.push:
        _layersKey.currentState!.push(_router.stack.last);
        _stack.notify();
        break;
      case PathRouterGoToTransition.pop:
        _layersKey.currentState!.pop();
        _stack.notify();
        break;
      case PathRouterGoToTransition.replace:
        _layersKey.currentState!.replace(_router.stack, animate: true);
        _stack.notify();
        break;
      case PathRouterGoToTransition.none:
        _layersKey.currentState!.makeRouteVisible();
        break;
    }
  }

  void remove(String path) {
    final transition = _router.remove(
        path,
        onRemovedRoute: (ShellRoute route) {
          assert(mounted);
          route.dispose(context);
        });
    _nodes.notify();
    switch (transition) {
      case PathRouterRemoveTransition.pop:
        _layersKey.currentState!.pop();
        _stack.notify();
        break;
      case PathRouterRemoveTransition.replace:
        _layersKey.currentState!.replace(_router.stack, animate: true);
        _stack.notify();
        break;
      case PathRouterRemoveTransition.none:
        break;
    }
  }

  void detach(String path, String newFragment) {
    final transition = _router.detach(path, newFragment);
    _nodes.notify();
    switch (transition) {
      case PathRouterDetachTransition.replace:
        _layersKey.currentState!.replace(_router.stack, animate: false);
        _stack.notify();
        break;
      case PathRouterDetachTransition.none:
        break;
    }
  }

  void _handleLayersPop(bool didPopAlready) {
    final transition = _router.remove(
        _router.stack.last.path,
        onRemovedRoute: (ShellRoute route) {
          assert(mounted);
          route.dispose(context);
        });
    assert(transition == PathRouterRemoveTransition.pop);
    _nodes.notify();
    _stack.notify();
    // If _Layers hasn't popped yet, we need to tell it to do so now
    if (!didPopAlready) {
      _layersKey.currentState!.pop();
    }
  }

  void _updateNodeDependencies(Iterable<PathNode<ShellRoute>> nodes) {
    for (final node in nodes) {
      node.route.didChangeDependencies(context);
      _updateNodeDependencies(node.children.values);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.root._initialized) {
      widget.root.initState(context);
      widget.root._initialized = true;
    }
    widget.root.didChangeDependencies(context);
    _updateNodeDependencies(_router.nodes.values);
  }

  @override
  Widget build(BuildContext context) {
    final rootComponents = widget.root.build(context, _nodes, _stack);
    return _ShellScope(
      state: this,
      child: _Layers(
        key: _layersKey,
        rootComponents: rootComponents,
        onPop: _handleLayersPop));
  }
}

typedef _LayersPopCallback = void Function(bool didPopAlready);

class _Layers extends StatefulWidget {

  _Layers({
    Key? key,
    required this.rootComponents,
    required this.onPop
  }) : super(key: key);

  final RootComponents rootComponents;

  final _LayersPopCallback onPop;

  @override
  _LayersState createState() => _LayersState();
}

enum _LayersMode {
  idleAtEmpty,
  idleAtRoot,
  idleAtRoute,
  idleAtOptions,

  // navigation when idleAtEmpty or idleAtRoute
  pushFromOrPopToEmpty,

  // navigation when idleAtRoot
  popFromRootToEmpty,
  popAtRoot,
  replaceAtRoot,
  replaceFromRoot,

  // navigation when idleAtRoute
  pushAtRoute,
  popAtRoute,
  replaceAtRoute,

  // drag from idleAtRoute
  dragToPop,
  dragToPopToEmpty,

  // drag from idleAtRoot or idleAtRoute
  dragToExpandOrCollapseRoute,

  // drag from idleAtRoute or idleAtOptions
  dragToExpandOrCollapseOptions,

  // expand from idleAtRoot or idleAtRoute
  expandOrCollapseRoute,

  // expand from idleAtRoute or idleAtOptions
  expandOrCollapseOptions,
}

enum _DrawersTransition {
  // root drawer
  dragToOrFromRoot,
  revealOrHideRoot,

  // entry drawer
  dragToOrFromEntry,
  revealOrHideEntry,
}

class _LayersState extends State<_Layers> with SingleTickerProviderStateMixin { 

  late final _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
      vsync: this);

  final _routes = <ShellRoute>[];
  var _mode = _LayersMode.idleAtEmpty;
  int? _replacedEntriesLength;
  ShellRoute? _hiddenRoute;
  ShellRoute? _visibleRoute;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void push(ShellRoute route) {
    // Push relies on the build method using the routes in [_routes], so there shouldn't be any overrides.
    assert(_hiddenRoute == null);
    assert(_visibleRoute == null);
    setState(() {
      if (_routes.isEmpty) {
        assert(_mode == _LayersMode.idleAtEmpty);
        _mode = _LayersMode.pushFromOrPopToEmpty;
      } else {
        switch (_mode) {
          case _LayersMode.idleAtRoot:
            _mode = _LayersMode.replaceFromRoot;
            break;
          case _LayersMode.idleAtRoute:
            _mode = _LayersMode.pushAtRoute;
            break;
          default:
            throw StateError('Tried to push to _Layers while it was not idling at root or route layers');
        }
      }
      _routes.add(route);
      _controller.forward(from: 0.0).then((_) {
        setState(() {
          _mode = _LayersMode.idleAtRoute;
        });
      });
    });
  }

  void pop() {
    assert(_hiddenRoute == null);
    assert(_visibleRoute == null);
    setState(() {
      _LayersMode modeAfterPopped;
      if (_routes.length == 1) {
        switch (_mode) {
          case _LayersMode.idleAtRoot:
            _mode = _LayersMode.popFromRootToEmpty;
            break;
          case _LayersMode.idleAtRoute:
            _mode = _LayersMode.pushFromOrPopToEmpty;
            break;
          default:
            throw StateError('Tried to pop from _Layers while it was not idling at root or route layers. Transition was: $_mode');
        }
        modeAfterPopped = _LayersMode.idleAtEmpty;
      } else {
        switch (_mode) {
          case _LayersMode.idleAtRoot:
            _mode = _LayersMode.popAtRoot;
            modeAfterPopped = _LayersMode.idleAtRoot;
            break;
          case _LayersMode.idleAtRoute:
            _mode = _LayersMode.popAtRoute;
            modeAfterPopped = _LayersMode.idleAtRoute;
            break;
          default:
            throw StateError('Tried to pop from _Layers while it was not idling at root or route layers. Transition was: $_mode');
        }
      }

      _controller.reverse(from: 1.0).then((_) {
        setState(() {
          _routes.removeLast();
          _mode = modeAfterPopped;
        });
      });
    });
  }

  void replace(List<ShellRoute> stack, { required bool animate }) {
    setState(() {
      if (animate) {
        _hiddenRoute = _routes.isNotEmpty ? _routes.last : null;
        _replacedEntriesLength = _routes.length;
        _routes.clear();
        _routes.addAll(stack);
        switch (_mode) {
          case _LayersMode.idleAtEmpty:
            _mode = _LayersMode.pushFromOrPopToEmpty;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _mode = _LayersMode.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
              });
            });
            break;
          case _LayersMode.idleAtRoot:
            _mode = _LayersMode.replaceFromRoot;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _mode = _LayersMode.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
              });
            });
            break;
          case _LayersMode.idleAtRoute:
            _mode = _LayersMode.replaceAtRoute;
            _controller.forward(from: 0.0).then((_) {
              _mode = _LayersMode.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
            });
            break;
          default:
            throw StateError('Tried to replace the _Layers stack while it was not idling at empty, root, or route layers. Transition was: $_mode');
        }
      } else {
        _routes.clear();
        _routes.addAll(stack);
      }
    });
  }

  void makeRouteVisible() {
    assert(_mode == _LayersMode.idleAtRoot);
    setState(() {
      _mode = _LayersMode.expandOrCollapseRoute;
      _controller.forward(from: 0.0).then((_) {
        setState(() {
          _mode = _LayersMode.idleAtRoute;
        });
      });
    });
  }

  void _handleDragUpdate(
      DragUpdateDetails details, {
      required double draggableExtent
    }) {
    _controller.value -= details.primaryDelta! / draggableExtent;
  }

  void _handleDragEnd(
      DragEndDetails? details, {
      required double draggableExtent,
      required _LayersMode modeIfAnimating,
      required VoidCallback onDismissed,
      required VoidCallback onCompleted,
    }) {
    setState(() {
      if (_controller.isDismissed) {
        onDismissed();
        return;
      }
      if (_controller.isCompleted) {
        onCompleted();
        return;
      }

      assert(details != null);

      _mode = modeIfAnimating;

      if (details!.primaryVelocity!.abs() > 700) {
        final flingVelocity = -(details.primaryVelocity! / draggableExtent);
        _controller.fling(velocity: flingVelocity).then((_) {
          setState(() {
            if (_controller.isDismissed) {
              onDismissed();
            } else {
              assert(_controller.isCompleted);
              onCompleted();
            }
          });
        });
      } else if (_controller.value < 0.5) {
        _controller.reverse().then((_) {
          setState(() {
            onDismissed();
          });
        });
      } else {
        _controller.forward().then((_) {
          setState(() {
            onCompleted();
          });
        });
      }
    });
  }

  late double _contentSheetDraggableExtent;

  void _handleContentSheetDragStart(DragStartDetails _) {
    setState(() => _mode = _LayersMode.dragToExpandOrCollapseRoute);
  }

  void _handleContentSheetDragUpdate(DragUpdateDetails details) {
    _handleDragUpdate(details, draggableExtent: _contentSheetDraggableExtent);
  }

  void _handleContentSheetDragEnd([DragEndDetails? details]) {
    _handleDragEnd(
      details,
      draggableExtent: _contentSheetDraggableExtent,
      modeIfAnimating: _LayersMode.expandOrCollapseRoute,
      onDismissed: () {
        _mode = _LayersMode.idleAtRoot;
      },
      onCompleted: () {
        _mode = _LayersMode.idleAtRoute;
      });
  }

  final _contentBodyKey = GlobalKey();
  double get _contentBodyWidth {
    return (_contentBodyKey.currentContext!.findRenderObject() as RenderBox).size.width;
  }

  void _handleBodyDragStart(DragStartDetails _) {
    setState(() {
      if (_routes.length == 1) {
        _mode = _LayersMode.dragToPopToEmpty;
      } else {
        _mode = _LayersMode.dragToPop;
      }
    });
  }

  void _handleBodyDragUpdate(DragUpdateDetails details) {
    _handleDragUpdate(details, draggableExtent: _contentBodyWidth);
  }

  void _handleBodyDragEnd([DragEndDetails? details]) {
    final _LayersMode modeIfAnimating;
    if (_mode == _LayersMode.dragToPopToEmpty) {
      modeIfAnimating = _LayersMode.pushFromOrPopToEmpty;
    } else if (_mode == _LayersMode.dragToPop) {
      modeIfAnimating = _LayersMode.popAtRoute;
    } else {
      modeIfAnimating = _mode;
    }
    _handleDragEnd(
      details,
      draggableExtent: _contentBodyWidth,
      modeIfAnimating: modeIfAnimating,
      onDismissed: () {
        switch (_mode) {
          case _LayersMode.dragToPopToEmpty:
          case _LayersMode.pushFromOrPopToEmpty:
            _mode = _LayersMode.idleAtEmpty;
            break;
          case _LayersMode.dragToPop:
          case _LayersMode.popAtRoute:
            _mode = _LayersMode.idleAtRoute;
            _controller.value = 1.0;
            break;
          default:
            _mode = _LayersMode.idleAtRoute;
            _controller.value = 1.0;
            return;
        }
        _routes.removeLast();
        widget.onPop(true);
      },
      onCompleted: () {
        _mode = _LayersMode.idleAtRoute;
      });
  }

  late double _optionsSheetDraggableExtent;

  void _handleOptionsSheetDragStart(DragStartDetails _) {
    setState(() {
      if (_mode == _LayersMode.idleAtRoute) {
        _controller.value = 0.0;
      }
      _mode = _LayersMode.dragToExpandOrCollapseOptions;
    });
  }

  void _handleOptionsSheetDragUpdate(DragUpdateDetails details) {
    _handleDragUpdate(details, draggableExtent: _optionsSheetDraggableExtent);
  }

  void _handleOptionsSheetDragEnd([DragEndDetails? details]) {
    _handleDragEnd(
      details,
      draggableExtent: _optionsSheetDraggableExtent,
      modeIfAnimating: _LayersMode.expandOrCollapseOptions,
      onDismissed: () {
        _mode = _LayersMode.idleAtRoute;
        _controller.value = 1.0;
      },
      onCompleted: () {
        _mode = _LayersMode.idleAtOptions;
      });
  }

  void _handlePop() {
    widget.onPop(false);
  }
  
  @override
  Widget build(BuildContext context) {
    final hiddenComponents = _hiddenRoute?.build(context) ??
        (_routes.length > 1 ? _routes[_routes.length - 2].build(context) : null);

    final visibleComponents = _visibleRoute?.build(context) ??
        (_routes.isNotEmpty ? _routes.last.build(context) : null);

    return Stack(
      children: <Widget>[
        _RootLayer(
          components: widget.rootComponents,
          animation: _controller,
          mode: _mode),
        _TitleLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          mode: _mode,
          replacedEntriesLength: _replacedEntriesLength,
          entriesLength: _routes.length,
          onPop: _handlePop),
        _ContentLayer(
          peekHandle: widget.rootComponents.handle,
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          mode: _mode,
          onDraggableSheetExtent: (double value) {
            _contentSheetDraggableExtent = value;
          },
          onSheetDragStart: _handleContentSheetDragStart,
          onSheetDragUpdate: _handleContentSheetDragUpdate,
          onSheetDragEnd: _handleContentSheetDragEnd,
          onSheetDragCancel: _handleContentSheetDragEnd,
          bodyKey: _contentBodyKey,
          onBodyDragStart: _handleBodyDragStart,
          onBodyDragUpdate: _handleBodyDragUpdate,
          onBodyDragEnd: _handleBodyDragEnd,
          onBodyDragCancel: _handleBodyDragEnd),
        _OptionsLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          mode: _mode,
          onDraggableExtent: (double value) {
            _optionsSheetDraggableExtent = value;
          },
          onDragStart: _handleOptionsSheetDragStart,
          onDragUpdate: _handleOptionsSheetDragUpdate,
          onDragEnd: _handleOptionsSheetDragEnd,
          onDragCancel: _handleOptionsSheetDragEnd)
      ]);
  }
}

class _RootLayer extends StatelessWidget {

  _RootLayer({
    Key? key,
    required this.components,
    required this.animation,
    required this.mode
  }) : super(key: key);

  final RootComponents components;

  final Animation<double> animation;

  final _LayersMode mode;

  Animation<double> get _opacity {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysCompleteAnimation;
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysDismissedAnimation;
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return ReverseAnimation(animation);
    }
  }

  bool get _ignorePointers {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
        return false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _ignorePointers,
      child: FadeTransition(
        opacity: _opacity,
        child: components.layer));
  }
}

class _TitleLayer extends StatelessWidget {

  _TitleLayer({
    Key? key,
    this.hiddenComponents,
    this.visibleComponents,
    required this.animation,
    required this.mode,
    this.replacedEntriesLength,
    required this.entriesLength,
    this.onPop
  }) : super(key: key) {
    _decorationTween = DecorationTween(
      begin: hiddenComponents?.titleDecoration ?? const BoxDecoration(),
      end: visibleComponents?.titleDecoration ?? const BoxDecoration());
  }

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersMode mode;

  final int? replacedEntriesLength;

  final int entriesLength;

  final VoidCallback? onPop;

  Animation<double> get _layerOpacity {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return animation;
    }
  }

  late final DecorationTween _decorationTween;

  Animation<Decoration> get _decoration {
    Animation<double> parent;
    switch (mode) {
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }

    return parent.drive(_decorationTween);
  }

  static final _kRotationTween = Tween<double>(
    begin: -1/4,
    end: 0.0);

  Animation<double> get _rotation {
    Animation<double> parent;
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.dragToPopToEmpty:
        parent = kAlwaysDismissedAnimation;
        break;
      case _LayersMode.idleAtRoot:
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseRoute:
      case _LayersMode.expandOrCollapseOptions:
        parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : kAlwaysCompleteAnimation);
        break;
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoot:
      case _LayersMode.popAtRoute:
      case _LayersMode.dragToPop:
        parent = (entriesLength == 2 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersMode.replaceAtRoot:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.replaceAtRoute:
        if (replacedEntriesLength! < 2) {
          parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : animation);
        } else {
          parent = (entriesLength > 2 ? kAlwaysCompleteAnimation : ReverseAnimation(animation));
        }
    }

    return parent.drive(_kRotationTween);
  }

  Animation<double> get _itemOpacity {
    switch (mode) {
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
        return animation;
      default:
        return kAlwaysCompleteAnimation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _layerOpacity,
      child: DecoratedBoxTransition(
        decoration: _decoration,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Toolbar(
            leading: Pressable(
              onPress: onPop,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0),
                child: RotationTransition(
                  turns: _rotation,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black)))),
            middle: Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: ReverseAnimation(_itemOpacity),
                  child: hiddenComponents?.titleMiddle),
                FadeTransition(
                  opacity: _itemOpacity,
                  child: visibleComponents?.titleMiddle)
              ]),
            trailing: Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: ReverseAnimation(_itemOpacity),
                  child: hiddenComponents?.titleTrailing),
                FadeTransition(
                  opacity: _itemOpacity,
                  child: visibleComponents?.titleTrailing)
              ])))));
  }
}

class _ContentLayer extends StatelessWidget {

  _ContentLayer({
    Key? key,
    required this.peekHandle,
    this.hiddenComponents,
    this.visibleComponents,
    required this.animation,
    required this.mode,
    required this.onDraggableSheetExtent,
    required this.onSheetDragStart,
    required this.onSheetDragUpdate,
    required this.onSheetDragEnd,
    required this.onSheetDragCancel,
    required this.bodyKey,
    required this.onBodyDragStart,
    required this.onBodyDragUpdate,
    required this.onBodyDragEnd,
    required this.onBodyDragCancel,
  }) : super(key: key);

  final Widget peekHandle;

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersMode mode;

  final ValueChanged<double> onDraggableSheetExtent;

  final GestureDragStartCallback onSheetDragStart;

  final GestureDragUpdateCallback onSheetDragUpdate;

  final GestureDragEndCallback onSheetDragEnd;

  final GestureDragCancelCallback onSheetDragCancel;

  final GlobalKey bodyKey;

  final GestureDragStartCallback onBodyDragStart;

  final GestureDragUpdateCallback onBodyDragUpdate;

  final GestureDragEndCallback onBodyDragEnd;

  final GestureDragCancelCallback onBodyDragCancel;

  Animation<double> get _sheetPosition {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return animation;
    }
  }

  SheetWithHandleMode get _sheetMode {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.dragToPopToEmpty:
        return SheetWithHandleMode.hideOrExpand;
      case _LayersMode.idleAtRoot:
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseRoute:
      case _LayersMode.expandOrCollapseOptions:
        return SheetWithHandleMode.peekOrExpand;
      case _LayersMode.popFromRootToEmpty:
        return SheetWithHandleMode.hideOrPeek;
    }
  }

  Animation<double> get _bodyOpacity {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return animation;
    }
  }

  static final _kHiddenBodyPositionTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-(1.0/3.0), 0.0));

  Animation<Offset> get _hiddenBodyPosition {
    Animation<double> parent;
    switch (mode) {
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }
    return parent.drive(_kHiddenBodyPositionTween);
  }

  static final _kVisibleBodyPositionTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero);

  Animation<Offset> get _visibleBodyPosition {
    Animation<double> parent;
    switch (mode) {
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }
    return parent.drive(_kVisibleBodyPositionTween);
  }

  Animation<double> get _hiddenHandleOpacity {
    switch (mode) {
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
        return ReverseAnimation(animation);
      default:
        return kAlwaysDismissedAnimation;
    }
  }

  Animation<double> get _visibleHandleOpacity {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersMode.replaceFromRoot:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return animation;
    }
  }

  Animation<double> get _peekHandleOpacity {
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoute:
      case _LayersMode.idleAtOptions:
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        return kAlwaysDismissedAnimation;
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        return kAlwaysCompleteAnimation;
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        return ReverseAnimation(animation);
    }
  }

  bool get _ignoreSheetDrag {
    switch (mode) {
      case _LayersMode.idleAtRoot:
      case _LayersMode.idleAtRoute:
      case _LayersMode.dragToExpandOrCollapseRoute:
        return false;
      default:
        return true;
    }
  }

  bool get _ignoreBodyDrag {
    switch (mode) {
      case _LayersMode.idleAtRoute:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToPop:
        return false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.mediaPadding.top + Toolbar.kHeight),
      child: SheetWithHandle(
        animation: _sheetPosition,
        mode: _sheetMode,
        ignoreDrag: _ignoreSheetDrag,
        onDraggableExtent: onDraggableSheetExtent,
        onDragStart: onSheetDragStart,
        onDragUpdate: onSheetDragUpdate,
        onDragEnd: onSheetDragEnd,
        onDragCancel: onSheetDragCancel,
        body: Material(
          child: IgnorePointer(
            ignoring: _ignoreBodyDrag,
            child: IgnoredDecoration(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor),
              child: FadeTransition(
                opacity: _bodyOpacity,
                child: Stack(
                  key: bodyKey,
                  children: <Widget>[
                    SlideTransition(
                      position: _hiddenBodyPosition,
                      child: hiddenComponents?.contentBody),
                    SlideTransition(
                      position: _visibleBodyPosition,
                      child: visibleComponents?.contentBody),
                    LTRDragDetector(
                      onDragStart: onBodyDragStart,
                      onDragUpdate: onBodyDragUpdate,
                      onDragEnd: onBodyDragEnd,
                      onDragCancel: onBodyDragCancel,
                      child: SizedBox.expand())
                  ]))))),
        handle: IgnorePointer(
          ignoring: mode != _LayersMode.idleAtRoute,
          child: SizedBox(
            height: kExpandedHandleHeight,
            child: Center(
              child: Stack(
                children: <Widget>[
                  FadeTransition(
                    opacity: _hiddenHandleOpacity,
                    child: _buildHandleWithDecoration(
                      context,
                      hiddenComponents?.contentHandle ?? const SizedBox.expand(),
                      bottomBorder: true)),
                  FadeTransition(
                    opacity: _visibleHandleOpacity,
                    child: _buildHandleWithDecoration(
                      context,
                      visibleComponents?.contentHandle ?? const SizedBox.expand(),
                      bottomBorder: true))
                ])))),
        peekHandle: IgnorePointer(
          ignoring: mode != _LayersMode.idleAtRoot,
          child: SizedBox(
            height: kCollapsedHandleHeight,
            child: RRectTopBorder(
              radius: 16.0,
              width: 0.0,
              color: Colors.grey,
              child: Center(
                child: FadeTransition(
                  opacity: _peekHandleOpacity,
                  child: _buildHandleWithDecoration(
                    context,
                    peekHandle,
                    bottomBorder: false))))))));
  }
}

class _OptionsLayer extends StatelessWidget {

  _OptionsLayer({
    Key? key,
    this.hiddenComponents,
    this.visibleComponents,
    required this.animation,
    required this.mode,
    required this.onDraggableExtent,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel
  }) : super(key: key);

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersMode mode;

  final ValueChanged<double> onDraggableExtent;

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  static Animation<double> _hideOrPeekAnimation(Animation<double> parent) {
    return CurvedAnimation(
      parent: parent,
      curve: const Interval(0.66, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> sheetPosition;
    SheetWithHandleMode sheetMode;
    Animation<double> hiddenHandleOpacity;
    Animation<double> visibleHandleOpacity;
    Animation<double> bodyOpacity;
    Animation<double> barrierOpacity;
    bool ignoreDrag;
    switch (mode) {
      case _LayersMode.idleAtEmpty:
      case _LayersMode.idleAtRoot:
      case _LayersMode.popFromRootToEmpty:
      case _LayersMode.popAtRoot:
      case _LayersMode.replaceAtRoot:
        sheetPosition = hiddenHandleOpacity = visibleHandleOpacity =
            bodyOpacity = barrierOpacity = kAlwaysDismissedAnimation;
        sheetMode = SheetWithHandleMode.hideOrPeek;
        ignoreDrag = true;
        break;
      case _LayersMode.idleAtRoute:
        if (visibleComponents?.optionsHandle != null) {
          sheetMode = SheetWithHandleMode.peekOrExpand;
          visibleHandleOpacity = kAlwaysCompleteAnimation;
          ignoreDrag = false;
        } else {
          sheetMode = SheetWithHandleMode.hideOrPeek;
          visibleHandleOpacity = kAlwaysDismissedAnimation;
          ignoreDrag = true;
        }
        sheetPosition = hiddenHandleOpacity = bodyOpacity = barrierOpacity = kAlwaysDismissedAnimation;
        break;
      case _LayersMode.idleAtOptions:
        sheetPosition = bodyOpacity = barrierOpacity = kAlwaysCompleteAnimation;
        sheetMode = SheetWithHandleMode.peekOrExpand;
        hiddenHandleOpacity = visibleHandleOpacity = kAlwaysDismissedAnimation;
        ignoreDrag = false;
        break;
      case _LayersMode.pushFromOrPopToEmpty:
      case _LayersMode.replaceFromRoot:
      case _LayersMode.dragToPopToEmpty:
      case _LayersMode.dragToExpandOrCollapseRoute:
      case _LayersMode.expandOrCollapseRoute:
        if (visibleComponents?.optionsHandle != null) {
          sheetPosition = _hideOrPeekAnimation(animation);
          visibleHandleOpacity = kAlwaysCompleteAnimation;
        } else {
          sheetPosition = visibleHandleOpacity = kAlwaysDismissedAnimation;
        }
        sheetMode = SheetWithHandleMode.hideOrPeek;
        hiddenHandleOpacity = bodyOpacity = barrierOpacity = kAlwaysDismissedAnimation;
        ignoreDrag = true;
        break;
      case _LayersMode.pushAtRoute:
      case _LayersMode.popAtRoute:
      case _LayersMode.replaceAtRoute:
      case _LayersMode.dragToPop:
        if (hiddenComponents?.optionsHandle != null) {
          if (visibleComponents?.optionsHandle != null) {
            sheetPosition = kAlwaysCompleteAnimation;
            visibleHandleOpacity = animation;
          } else {
            sheetPosition = _hideOrPeekAnimation(ReverseAnimation(animation));
            visibleHandleOpacity = kAlwaysDismissedAnimation;
          }
          hiddenHandleOpacity = ReverseAnimation(animation);
        } else if (visibleComponents?.optionsHandle != null) {
          sheetPosition = _hideOrPeekAnimation(animation);
          hiddenHandleOpacity = kAlwaysDismissedAnimation;
          visibleHandleOpacity = animation;
        } else {
          sheetPosition = kAlwaysDismissedAnimation;
          hiddenHandleOpacity = visibleHandleOpacity = kAlwaysDismissedAnimation;
        }
        sheetMode = SheetWithHandleMode.hideOrPeek;
        bodyOpacity = barrierOpacity = kAlwaysDismissedAnimation;
        ignoreDrag = true;
        break;
      case _LayersMode.dragToExpandOrCollapseOptions:
      case _LayersMode.expandOrCollapseOptions:
        sheetPosition = animation;
        sheetMode = SheetWithHandleMode.peekOrExpand;
        hiddenHandleOpacity = kAlwaysDismissedAnimation;
        visibleHandleOpacity = ReverseAnimation(animation);
        bodyOpacity = barrierOpacity = animation;
        ignoreDrag = (mode == _LayersMode.expandOrCollapseOptions);
        break;
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: barrierOpacity != kAlwaysCompleteAnimation,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: FadeTransition(
              opacity: barrierOpacity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54),
                child: SizedBox.expand())))),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: SheetWithHandle(
              animation: sheetPosition,
              mode: sheetMode,
              ignoreDrag: ignoreDrag,
              onDraggableExtent: onDraggableExtent,
              onDragStart: onDragStart,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              onDragCancel: onDragCancel,
              body: FadeTransition(
                opacity: bodyOpacity,
                child: visibleComponents?.optionsBody),
              handle: SizedBox(
                height: kCollapsedHandleHeight,
                child: RRectTopBorder(
                  radius: 16.0,
                  width: 0.0,
                  color: Colors.grey,
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        FadeTransition(
                          opacity: hiddenHandleOpacity,
                          child: _buildHandleWithDecoration(
                            context,
                            hiddenComponents?.optionsHandle ?? const SizedBox.expand(),
                            bottomBorder: false)),
                        FadeTransition(
                          opacity: visibleHandleOpacity,
                          child: _buildHandleWithDecoration(
                            context,
                            visibleComponents?.optionsHandle ?? const SizedBox.expand(),
                            bottomBorder: false)),
                      ])))))))
      ]);
  }
}
