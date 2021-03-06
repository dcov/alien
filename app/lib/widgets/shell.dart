import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/manual_value_notifier.dart';
import '../utils/path_router.dart';
import '../widgets/ignored_decoration.dart';
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
      onUpdateRoute: onUpdateRoute
    );

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
        break;
    }
    _nodes.notify();
  }

  void remove(String path) {
    final transition = _router.remove(path);
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
    _nodes.notify();
  }

  void detach(String path, String newFragment) {
    final transition = _router.detach(path, newFragment);
    switch (transition) {
      case PathRouterDetachTransition.replace:
        _layersKey.currentState!.replace(_router.stack, animate: false);
        _stack.notify();
        break;
      case PathRouterDetachTransition.none:
        break;
    }
    _nodes.notify();
  }

  void _handleLayersPop() {
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
        onPopEntry: _handleLayersPop));
  }
}

class _Layers extends StatefulWidget {

  _Layers({
    Key? key,
    required this.rootComponents,
    required this.onPopEntry
  }) : super(key: key);

  final RootComponents rootComponents;

  final VoidCallback onPopEntry;

  @override
  _LayersState createState() => _LayersState();
}

enum _LayersTransition {
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

  var _routes = <ShellRoute>[];
  var _layersTransition = _LayersTransition.idleAtEmpty;
  int? _replacedEntriesLength;
  ShellRoute? _hiddenRoute;
  ShellRoute? _visibleRoute;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void push(ShellRoute route) {
    setState(() {
      if (_routes.isEmpty) {
        assert(_layersTransition == _LayersTransition.idleAtEmpty);
        _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
        _controller.forward(from: 0.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
          });
        });
      } else {
        switch (_layersTransition) {
          case _LayersTransition.idleAtRoot:
            _layersTransition = _LayersTransition.replaceFromRoot;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoute;
              });
            });
            break;
          case _LayersTransition.idleAtRoute:
            _layersTransition = _LayersTransition.pushAtRoute;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoute;
              });
            });
            break;
          default:
            throw StateError('Tried to push to _Layers while it was not idling at root or route layers');
        }
      }
      _routes.add(route);
    });
  }

  void pop() {
    setState(() {
      final removed = _routes.removeLast();
      _hiddenRoute = _routes.isNotEmpty ? _routes.last : null;
      _visibleRoute = removed;
      if (_routes.isEmpty) {
        switch (_layersTransition) {
          case _LayersTransition.idleAtRoot:
            _layersTransition = _LayersTransition.popFromRootToEmpty;
            _controller.reverse(from: 1.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtEmpty;
                _hiddenRoute = null;
                _visibleRoute = null;
              });
            });
            break;
          case _LayersTransition.idleAtRoute:
            _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
            _controller.reverse(from: 1.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtEmpty;
                _hiddenRoute = null;
                _visibleRoute = null;
              });
            });
            break;
          default:
            throw StateError('Tried to pop from _Layers while it was not idling at root or route layers. Transition was: $_layersTransition');
        }
      } else {
        switch (_layersTransition) {
          case _LayersTransition.idleAtRoot:
            _layersTransition = _LayersTransition.popAtRoot;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoot;
                _hiddenRoute = null;
                _visibleRoute = null;
              });
            });
            break;
          case _LayersTransition.idleAtRoute:
            _layersTransition = _LayersTransition.popAtRoute;
            _controller.reverse(from: 1.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoute;
                _hiddenRoute = null;
                _visibleRoute = null;
              });
            });
            break;
          default:
            throw StateError('Tried to pop from _Layers while it was not idling at root or route layers. Transition was: $_layersTransition');
        }
      }
    });
  }

  void replace(List<ShellRoute> stack, { required bool animate }) {
    setState(() {
      if (animate) {
        _hiddenRoute = _routes.isNotEmpty ? _routes.last : null;
        _replacedEntriesLength = _routes.length;
        _routes = stack;
        switch (_layersTransition) {
          case _LayersTransition.idleAtEmpty:
            _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
              });
            });
            break;
          case _LayersTransition.idleAtRoot:
            _layersTransition = _LayersTransition.replaceFromRoot;
            _controller.forward(from: 0.0).then((_) {
              setState(() {
                _layersTransition = _LayersTransition.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
              });
            });
            break;
          case _LayersTransition.idleAtRoute:
            _layersTransition = _LayersTransition.replaceAtRoute;
            _controller.forward(from: 0.0).then((_) {
              _layersTransition = _LayersTransition.idleAtRoute;
              _hiddenRoute = null;
              _replacedEntriesLength = null;
            });
            break;
          default:
            throw StateError('Tried to replace the _Layers stack while it was not idling at empty, root, or route layers. Transition was: $_layersTransition');
        }
      } else {
        _routes = stack;
      }
    });
  }

  void _handleSheetDragUpdate(
      DragUpdateDetails details, {
      required double expandableHeight
    }) {
    _controller.value -= details.primaryDelta! / expandableHeight;
  }

  void _handleSheetDragEnd({
      DragEndDetails? details,
      required double expandableHeight,
      required _LayersTransition transition,
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

      _layersTransition = transition;

      if (details!.velocity.pixelsPerSecond.dy.abs() > 700) {
        final flingVelocity = -(details.velocity.pixelsPerSecond.dy / expandableHeight);
        _controller.fling(velocity: flingVelocity).then((_) {
          setState(() {
            if (flingVelocity < 0.0) {
              onDismissed();
            } else {
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

  void _handleContentDragStart(DragStartDetails _) {
    setState(() => _layersTransition = _LayersTransition.dragToExpandOrCollapseRoute);
  }

  void _handleContentDragUpdate(DragUpdateDetails details) {
    _handleSheetDragUpdate(details, expandableHeight: _contentSheetDraggableExtent);
  }

  void _handleContentDragEnd([DragEndDetails? details]) {
    _handleSheetDragEnd(
      details: details,
      expandableHeight: _contentSheetDraggableExtent,
      transition: _LayersTransition.expandOrCollapseRoute,
      onDismissed: () {
        _layersTransition = _LayersTransition.idleAtRoot;
      },
      onCompleted: () {
        _layersTransition = _LayersTransition.idleAtRoute;
      });
  }

  late double _optionsSheetDraggableExtent;

  void _handleOptionsDragStart(DragStartDetails _) {
    setState(() {
      if (_layersTransition == _LayersTransition.idleAtRoute) {
        _controller.value = 0.0;
      }
      _layersTransition = _LayersTransition.dragToExpandOrCollapseOptions;
    });
  }

  void _handleOptionsDragUpdate(DragUpdateDetails details) {
    _handleSheetDragUpdate(details, expandableHeight: _optionsSheetDraggableExtent);
  }

  void _handleOptionsDragEnd([DragEndDetails? details]) {
    _handleSheetDragEnd(
      details: details,
      expandableHeight: _optionsSheetDraggableExtent,
      transition: _LayersTransition.expandOrCollapseOptions,
      onDismissed: () {
        _layersTransition = _LayersTransition.idleAtRoute;
        _controller.value = 1.0;
      },
      onCompleted: () {
        _layersTransition = _LayersTransition.idleAtOptions;
      });
  }
  
  @override
  Widget build(BuildContext context) {
    final hiddenComponents = _hiddenRoute?.build(context) ??
        (_routes.length > 2 ? _routes[_routes.length - 2].build(context) : null);

    final visibleComponents = _visibleRoute?.build(context) ??
        (_routes.isNotEmpty ? _routes.last.build(context) : null);

    return Stack(
      children: <Widget>[
        _RootLayer(
          components: widget.rootComponents,
          animation: _controller,
          transition: _layersTransition),
        _TitleLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          replacedEntriesLength: _replacedEntriesLength,
          entriesLength: _routes.length,
          onPopEntry: widget.onPopEntry),
        _ContentLayer(
          peekHandle: widget.rootComponents.handle,
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          onDraggableExtent: (double value) {
            _contentSheetDraggableExtent = value;
          },
          onPopEntry: widget.onPopEntry,
          onDragStart: _handleContentDragStart,
          onDragUpdate: _handleContentDragUpdate,
          onDragEnd: _handleContentDragEnd,
          onDragCancel: _handleContentDragEnd),
        _OptionsLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          onDraggableExtent: (double value) {
            _optionsSheetDraggableExtent = value;
          },
          onDragStart: _handleOptionsDragStart,
          onDragUpdate: _handleOptionsDragUpdate,
          onDragEnd: _handleOptionsDragEnd,
          onDragCancel: _handleOptionsDragEnd)
      ]);
  }
}

class _RootLayer extends StatelessWidget {

  _RootLayer({
    Key? key,
    required this.components,
    required this.animation,
    required this.transition
  }) : super(key: key);

  final RootComponents components;

  final Animation<double> animation;

  final _LayersTransition transition;

  Animation<double> get _opacity {
    switch (transition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return ReverseAnimation(animation);
    }
  }

  bool get _ignorePointers {
    switch (transition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
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
    required this.layersTransition,
    this.replacedEntriesLength,
    required this.entriesLength,
    this.onPopEntry
  }) : super(key: key) {
    _decorationTween = DecorationTween(
      begin: hiddenComponents?.titleDecoration ?? const BoxDecoration(),
      end: visibleComponents?.titleDecoration ?? const BoxDecoration());
  }

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final int? replacedEntriesLength;

  final int entriesLength;

  final VoidCallback? onPopEntry;

  Animation<double> get _layerOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return animation;
    }
  }

  late final DecorationTween _decorationTween;

  Animation<Decoration> get _decoration {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
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
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.dragToPopToEmpty:
        parent = kAlwaysDismissedAnimation;
        break;
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseOptions:
        parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.pushAtRoute:
        parent = (entriesLength == 2 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.popAtRoot:
      case _LayersTransition.popAtRoute:
        parent = (entriesLength == 1 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.dragToPop:
        parent = (entriesLength == 2 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.replaceAtRoot:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.replaceAtRoute:
        if (replacedEntriesLength! < 2) {
          parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : animation);
        } else {
          parent = (entriesLength > 2 ? kAlwaysCompleteAnimation : ReverseAnimation(animation));
        }
    }

    return parent.drive(_kRotationTween);
  }

  Animation<double> get _itemOpacity {
    switch (layersTransition) {
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
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
              onPress: onPopEntry,
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
    required this.layersTransition,
    this.onPopEntry,
    required this.onDraggableExtent,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  }) : super(key: key);

  final Widget peekHandle;

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final VoidCallback? onPopEntry;

  final ValueChanged<double> onDraggableExtent;

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  Animation<double> get _sheetPosition {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return animation;
    }
  }

  SheetWithHandleMode get _sheetMode {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
        return SheetWithHandleMode.hideOrExpand;
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseOptions:
        return SheetWithHandleMode.peekOrExpand;
      case _LayersTransition.popFromRootToEmpty:
        return SheetWithHandleMode.hideOrPeek;
    }
  }

  Animation<double> get _bodyOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return animation;
    }
  }

  static final _kHiddenBodyPositionTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-(1.0/3.0), 0.0));

  Animation<Offset> get _hiddenBodyPosition {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.dragToPop:
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
    switch (layersTransition) {
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }
    return parent.drive(_kVisibleBodyPositionTween);
  }

  Animation<double> get _hiddenHandleOpacity {
    switch (layersTransition) {
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
        return ReverseAnimation(animation);
      default:
        return kAlwaysDismissedAnimation;
    }
  }

  Animation<double> get _visibleHandleOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return animation;
    }
  }

  Animation<double> get _peekHandleOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return ReverseAnimation(animation);
    }
  }

  bool get _ignoreDrag {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return true;
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return false;
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
        ignoreDrag: _ignoreDrag,
        onDraggableExtent: onDraggableExtent,
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onDragCancel: onDragCancel,
        body: IgnorePointer(
          ignoring: layersTransition != _LayersTransition.idleAtRoute,
          child: IgnoredDecoration(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor),
            child: FadeTransition(
              opacity: _bodyOpacity,
              child: Stack(
                children: <Widget>[
                  SlideTransition(
                    position: _hiddenBodyPosition,
                    child: hiddenComponents?.contentBody),
                  SlideTransition(
                    position: _visibleBodyPosition,
                    child: visibleComponents?.contentBody)
                ])))),
        handle: IgnorePointer(
          ignoring: layersTransition != _LayersTransition.idleAtRoute,
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
          ignoring: layersTransition != _LayersTransition.idleAtRoot,
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
    required this.layersTransition,
    required this.onDraggableExtent,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel
  }) : super(key: key);

  final RouteComponents? hiddenComponents;

  final RouteComponents? visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final ValueChanged<double> onDraggableExtent;

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  Animation<double> get _sheetPosition {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
      case _LayersTransition.idleAtRoute:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        if (visibleComponents?.optionsHandle != null) {
          return CurvedAnimation(
              parent: animation,
              curve: const Interval(0.66, 1.0));
        } else {
          return kAlwaysDismissedAnimation;
        }
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
        assert(hiddenComponents != null);
        if (hiddenComponents!.optionsHandle != null) {
          if (visibleComponents?.optionsHandle != null) {
            return kAlwaysDismissedAnimation;
          } else {
            return ReverseAnimation(animation);
          }
        } else if (visibleComponents?.optionsHandle != null) {
          return animation;
        } else {
          return kAlwaysDismissedAnimation;
        }
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return animation;
    }
  }

  SheetWithHandleMode get _sheetMode {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
        return SheetWithHandleMode.hideOrPeek;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return SheetWithHandleMode.peekOrExpand;
    }
  }

  Animation<double> get _handleOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtEmpty:
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.popFromRootToEmpty:
      case _LayersTransition.popAtRoot:
      case _LayersTransition.replaceAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.replaceFromRoot:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.idleAtOptions:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.pushAtRoute:
      case _LayersTransition.popAtRoute:
      case _LayersTransition.replaceAtRoute:
      case _LayersTransition.dragToPop:
        return animation;
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return ReverseAnimation(animation);
    }
  }

  Animation<double> get _bodyOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      default:
        return kAlwaysDismissedAnimation;
    }
  }

  Animation<double> get _barrierOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return animation;
      default:
        return kAlwaysDismissedAnimation;
    }
  }

  bool get _ignoreDrag {
    switch (layersTransition) {
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseOptions:
        return false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final handleOpacity = _handleOpacity;
    final barrierOpacity = _barrierOpacity;
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
              animation: _sheetPosition,
              mode: _sheetMode,
              ignoreDrag: _ignoreDrag,
              onDraggableExtent: onDraggableExtent,
              onDragStart: onDragStart,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              onDragCancel: onDragCancel,
              body: FadeTransition(
                opacity: _bodyOpacity,
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
                          opacity: ReverseAnimation(handleOpacity),
                          child: _buildHandleWithDecoration(
                            context,
                            hiddenComponents?.optionsHandle ?? const SizedBox.expand(),
                            bottomBorder: false)),
                        FadeTransition(
                          opacity: handleOpacity,
                          child: _buildHandleWithDecoration(
                            context,
                            visibleComponents?.optionsHandle ?? const SizedBox.expand(),
                            bottomBorder: false)),
                      ])))))))
      ]);
  }
}
