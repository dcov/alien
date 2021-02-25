import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/pressable.dart';
import '../widgets/sheet_with_handle.dart';
import '../widgets/toolbar.dart';
import '../widgets/widget_extensions.dart';

class ShellComponents {

  ShellComponents({
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

abstract class _ShellChild {

  bool _initialized = false;

  /// Called once by Shell to initialize any state that can be initialized through the BuildContext
  /// of Shell itself.
  void initState(BuildContext context) { }

  /// Called once by Shell dispose of any state that can be disposed through the BuildContext of
  /// Shell itself.
  void dispose(BuildContext context) { }
}

abstract class ShellRoute extends _ShellChild {

  String get path => _path!;
  String? _path;

  ShellComponents buildComponents(BuildContext context);

  Widget? buildDrawer(BuildContext context) => null;
}

class ShellNode {

  ShellNode({ required this.route });

  final ShellRoute route;

  late final children = UnmodifiableMapView<String, ShellNode>(_children);
  final _children = <String, ShellNode>{};
}

abstract class ShellRoot extends _ShellChild {

  Widget buildLayer(BuildContext context, Map<String, ShellNode> nodes);

  Widget? buildDrawer(BuildContext context) => null;
}

typedef ShellRouteFactory = ShellRoute Function();

typedef ShellRouteUpdater = void Function(ShellRoute route);

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
      required ShellRouteFactory onCreateRoute,
      required ShellRouteUpdater onUpdateRoute
    }) {
    _state.goTo(
        fullPath,
        onCreateRoute: onCreateRoute,
        onUpdateRoute: onUpdateRoute);
  }
}

class _ShellState extends State<Shell> {

  final _nodes = <String, ShellNode>{};

  var _currentRouteStack = <ShellRoute>[];

  void goTo(
      String fullPath, {
      required ShellRouteFactory onCreateRoute,
      required ShellRouteUpdater onUpdateRoute
    }) {
    final subPaths = fullPath.split("/");
    assert(subPaths.isNotEmpty);

    final routeStack = <ShellRoute>[];

    ShellNode? parentNode;
    for (var i = 0; i < subPaths.length; i++) {
      ShellNode? node;
      if (parentNode == null) {
        node = _nodes[subPaths[i]];
      } else {
        node = parentNode._children[subPaths[i]];
      }

      if (node == null) {
        assert(i == subPaths.length - 1,
            'Called goTo with $fullPath, but there was no parent at ${subPaths.sublist(0, i + 1).join('/')}');

        final newNode = ShellNode(route: onCreateRoute());
        newNode.route._path = fullPath;
        if (parentNode == null) {
          _nodes[fullPath] = newNode;
        } else {
          parentNode._children[fullPath] = newNode;
        }
        routeStack.add(newNode.route);
      } else {
        routeStack.add(node.route);
        if (i == subPaths.length - 1) {
          // If this is the end of the subPaths list then the node's path should match fullPath
          assert(node.route._path == fullPath);
          onUpdateRoute(node.route);
        } else {
          parentNode = node;
        }
      }
    }

    assert(routeStack.isNotEmpty);
    setState(() {
      _currentRouteStack = routeStack;
    });
  }

  void move(String fromPath, String toPath) {
    // TODO
  }

  void pop() {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.root._initialized) {
      widget.root.initState(context);
    }

    if (_currentRouteStack.isNotEmpty && !_currentRouteStack.last._initialized) {
      final route = _currentRouteStack.last;
      route.initState(context);
      route._initialized = true;
    }

    return _ShellScope(
      state: this,
      child: _Layers(
        rootLayer: widget.root.buildLayer(context, const {}),
        rootDrawer: widget.root.buildDrawer(context),
        routes: _currentRouteStack,
        onPopEntry: pop));
  }
}

class _Layers extends StatefulWidget {

  _Layers({
    Key? key,
    required this.rootLayer,
    this.rootDrawer,
    this.routes = const <ShellRoute>[],
    required this.onPopEntry
  }) : super(key: key);

  final Widget rootLayer;
  
  final Widget? rootDrawer;

  final List<ShellRoute> routes;

  final VoidCallback onPopEntry;

  @override
  _LayersState createState() => _LayersState();
}

enum _LayersTransition {
  // idle
  idleAtRoot,
  idleAtRoute,
  idleAtOptions,

  // navigation
  pushFromOrPopToEmpty,
  push,
  pop,
  replace,

  // drag
  dragToPop,
  dragToPopToEmpty,
  dragToExpandOrCollapseRoute,
  dragToExpandOrCollapseOptions,

  // expand/collapse
  expandOrCollapseRoute,
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

  late var _routes = List<ShellRoute>.of(widget.routes);

  var _layersTransition = _LayersTransition.idleAtRoot;

  int? _replacedEntriesLength;
  ShellRoute? _hiddenRoute;
  ShellRoute? _visibleRoute;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Layers oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldRoutes = _routes;
    final newRoutes = List.of(widget.routes);
    if (oldRoutes.isEmpty && newRoutes.isEmpty) {
      // If they're both empty we can't transition to or from anything.
      return;
    }

    setState(() {
      _routes = newRoutes;

      if (oldRoutes.isEmpty) {
        _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
        _hiddenRoute = null;
        _visibleRoute = _routes.last;
        _controller.forward(from: 0.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
            _visibleRoute = null;
          });
        });
        return;
      }

      if (newRoutes.isEmpty) {
        _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
        _hiddenRoute = null;
        _visibleRoute = oldRoutes.last;
        _controller.reverse(from: 1.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoot;
            _visibleRoute = null;
          });
        });
        return;
      }

      if (oldRoutes.last == newRoutes.last) {
        if (_layersTransition == _LayersTransition.idleAtRoot) {
          _layersTransition = _LayersTransition.expandOrCollapseRoute;
          _controller.forward(from: 0.0).then((_) {
            setState(() {
              _layersTransition = _LayersTransition.idleAtRoute;
            });
          });
        }
        return;
      }

      final lengthDiff = newRoutes.length - oldRoutes.length;
      if (lengthDiff == 1 && (oldRoutes.last == newRoutes[oldRoutes.length - 2])) {
        _layersTransition = _LayersTransition.push;
        _hiddenRoute = oldRoutes.last;
        _visibleRoute = newRoutes.last;
        _controller.forward(from: 0.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
            _hiddenRoute = null;
            _visibleRoute = null;
          });
        });
        return;
      }

      if (lengthDiff == -1 && (oldRoutes[oldRoutes.length - 2] == newRoutes.last)) {
        _layersTransition = _LayersTransition.pop;
        _hiddenRoute = newRoutes.last;
        _visibleRoute = oldRoutes.last;
        _controller.reverse(from: 1.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
            _hiddenRoute = null;
            _visibleRoute = null;
          });
        });
        return;
      }
      
      if (_layersTransition == _LayersTransition.idleAtRoot) {
        _layersTransition = _LayersTransition.expandOrCollapseRoute;
        _controller.forward(from: 0.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
          });
        });
        return;
      }

      _layersTransition = _LayersTransition.replace;
      _replacedEntriesLength = oldRoutes.length;
      _hiddenRoute = oldRoutes.last;
      _visibleRoute = newRoutes.last;
      _controller.forward(from: 0.0).then((_) {
        setState(() {
          _layersTransition = _LayersTransition.idleAtRoute;
          _replacedEntriesLength = null;
          _hiddenRoute = null;
          _visibleRoute = null;
        });
      });
    });
  }

  final _contentKey = GlobalKey(debugLabel: 'content layer key');
  double get _contentHeight {
    return (_contentKey.currentContext!.findRenderObject() as RenderBox).size.height;
  }

  void _handleContentDragStart(DragStartDetails details) {
    setState(() {
      _layersTransition = _LayersTransition.dragToExpandOrCollapseRoute;
    });
  }

  void _handleContentDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / _contentHeight;
  }

  void _handleContentDragEnd(DragEndDetails details) {
    setState(() {
      if (_controller.isDismissed) {
        _layersTransition = _LayersTransition.idleAtRoot;
        return;
      }

      if (_controller.isCompleted) {
        _layersTransition = _LayersTransition.idleAtRoute;
        return;
      }
      
      _layersTransition = _LayersTransition.expandOrCollapseRoute;

      // Is it a fling gesture?
      if (details.velocity.pixelsPerSecond.dy.abs() > 700) {
        final flingVelocity = -(details.velocity.pixelsPerSecond.dy / _contentHeight);
        _controller.fling(velocity: flingVelocity).then((_) {
          setState(() {
            if (flingVelocity < 0.0) {
              _layersTransition = _LayersTransition.idleAtRoot;
            } else {
              _layersTransition = _LayersTransition.idleAtRoute;
            }
          });
        });
      } else if (_controller.value > 0.5) {
        _controller.forward().then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoute;
          });
        });
      } else {
        _controller.reverse().then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtRoot;
          });
        });
      }
    });
  }

  void _handleContentDragCancel() {
    if (_layersTransition == _LayersTransition.dragToExpandOrCollapseRoute) {
      setState(() {
        assert(!_controller.isAnimating);
        _layersTransition = _controller.isDismissed ? _LayersTransition.idleAtRoot : _LayersTransition.idleAtRoute;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[
      widget.rootLayer
    ];
    if (_visibleRoute != null || _routes.isNotEmpty) {
      final ShellComponents? hiddenComponents;
      if (_hiddenRoute != null) {
        hiddenComponents = _hiddenRoute!.buildComponents(context);
      } else if (_routes.length > 2) {
        hiddenComponents = _routes[_routes.length - 2].buildComponents(context);
      } else {
        hiddenComponents = null;
      }

      final ShellComponents visibleComponents;
      if (_visibleRoute != null) {
        visibleComponents = _visibleRoute!.buildComponents(context);
      } else {
        visibleComponents = _routes.last.buildComponents(context);
      }

      layers.add(_TitleLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          replacedEntriesLength: _replacedEntriesLength,
          entriesLength: _routes.length,
          onPopEntry: widget.onPopEntry));
      
      layers.add(_ContentLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          contentKey: _contentKey,
          onPopEntry: widget.onPopEntry,
          onDragStart: _handleContentDragStart,
          onDragUpdate: _handleContentDragUpdate,
          onDragEnd: _handleContentDragEnd,
          onDragCancel: _handleContentDragCancel));

      layers.add(_OptionsLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition));
    }
    return Stack(children: layers);
  }
}

class _TitleLayer extends StatelessWidget {

  _TitleLayer({
    Key? key,
    this.hiddenComponents,
    required this.visibleComponents,
    required this.animation,
    required this.layersTransition,
    this.replacedEntriesLength,
    required this.entriesLength,
    this.onPopEntry
  }) : super(key: key) {
    assert((replacedEntriesLength == null && layersTransition != _LayersTransition.replace) ||
           (replacedEntriesLength != null && layersTransition == _LayersTransition.replace));
    _decorationTween = DecorationTween(
      begin: hiddenComponents?.titleDecoration ?? const BoxDecoration(),
      end: visibleComponents.titleDecoration ?? const BoxDecoration());
  }

  final ShellComponents? hiddenComponents;

  final ShellComponents visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final int? replacedEntriesLength;

  final int entriesLength;

  final VoidCallback? onPopEntry;

  static final _kPositionTween = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: Offset.zero);

  Animation<Offset> get _position {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
        // We are out of frame.
        parent = kAlwaysDismissedAnimation;
        break;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        // We are in frame
        parent = kAlwaysCompleteAnimation;
        break;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        // We are animating in or out of frame
        parent = animation;
    }

    return parent.drive(_kPositionTween);
  }


  late final DecorationTween _decorationTween;

  Animation<Decoration> get _decoration {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }

    return parent.drive(_decorationTween);
  }

  static final _kRotationTween = Tween<double>(
    begin: -((90 * (math.pi/180)) / 2),
    end: 0);

  Animation<double> get _rotation {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseOptions:
        parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
        parent = kAlwaysDismissedAnimation;
        break;
      case _LayersTransition.push:
        parent = (entriesLength == 2 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.pop:
        parent = (entriesLength == 1 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.dragToPop:
        parent = (entriesLength == 2 ? animation : kAlwaysCompleteAnimation);
        break;
      case _LayersTransition.replace:
        if (replacedEntriesLength! < 2) {
          parent = (entriesLength < 2 ? kAlwaysDismissedAnimation : animation);
        } else {
          parent = (entriesLength > 2 ? kAlwaysCompleteAnimation : ReverseAnimation(animation));
        }
    }

    return parent.drive(_kRotationTween);
  }

  Animation<double> get _opacity {
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
        return animation;
      default:
        return kAlwaysCompleteAnimation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _position,
      child: DecoratedBoxTransition(
        decoration: _decoration,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Toolbar(
            leading: Pressable(
              onPress: onPopEntry,
              child: RotationTransition(
                turns: _rotation,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black))),
            middle: Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: ReverseAnimation(_opacity),
                  child: hiddenComponents?.titleMiddle),
                FadeTransition(
                  opacity: _opacity,
                  child: visibleComponents.titleMiddle)
              ]),
            trailing: Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: ReverseAnimation(_opacity),
                  child: hiddenComponents?.titleTrailing),
                FadeTransition(
                  opacity: _opacity,
                  child: visibleComponents.titleTrailing)
              ])))));
  }
}

class _ContentLayer extends StatelessWidget {

  _ContentLayer({
    Key? key,
    this.hiddenComponents,
    required this.visibleComponents,
    required this.animation,
    required this.layersTransition,
    required this.contentKey,
    this.onPopEntry,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  }) : super(key: key);

  final ShellComponents? hiddenComponents;

  final ShellComponents visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final GlobalKey contentKey;

  final VoidCallback? onPopEntry;

  final GestureDragStartCallback onDragStart;

  final GestureDragUpdateCallback onDragUpdate;

  final GestureDragEndCallback onDragEnd;

  final GestureDragCancelCallback onDragCancel;

  Animation<double> get _layerPosition {
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
        return kAlwaysPeekAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return animation.drive(kExpandTween);
    }
  }

  static final _kHiddenBodyPositionTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-(1.0/3.0), 0.0));

  Animation<Offset> get _hiddenBodyPosition {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysDismissedAnimation;
    }

    return parent.drive(_kHiddenBodyPositionTween);
  }

  static final _kVisibleBodyPositionTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero);

  Animation<Offset> get _visibleBodyPosition {
    Animation<double> parent;
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.dragToPop:
        parent = animation;
        break;
      default:
        parent = kAlwaysCompleteAnimation;
    }

    return parent.drive(_kVisibleBodyPositionTween);
  }

  Animation<double> get _opacity {
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
        return animation;
      default:
        return kAlwaysCompleteAnimation;
    }
  }

  static int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.mediaPadding.top + Toolbar.kHeight),
      child: SheetWithHandle(
        key: contentKey,
        animation: _layerPosition,
        handle: GestureDetector(
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          onVerticalDragCancel: onDragCancel,
          child: Material(
            elevation: 2.0,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: SizedBox(
              height: 36.0,
              child: Stack(
                children: <Widget>[
                  FadeTransition(
                    opacity: ReverseAnimation(_opacity),
                    child: hiddenComponents?.contentHandle),
                  FadeTransition(
                    opacity: _opacity,
                    child: visibleComponents.contentHandle)
                ])))),
        body: Builder(
          builder: (_) {
            print('built content body: ${_buildCount++}');
            print('_visibleBodyPosition: ${_visibleBodyPosition.value}');
            return Stack(
              children: <Widget>[
                SlideTransition(
                  position: _hiddenBodyPosition,
                  child: hiddenComponents?.contentBody),
                SlideTransition(
                  position: _visibleBodyPosition,
                  child: visibleComponents.contentBody)
              ]);
          })));
  }
}

class _OptionsLayer extends StatelessWidget {

  _OptionsLayer({
    Key? key,
    this.hiddenComponents,
    required this.visibleComponents,
    required this.animation,
    required this.layersTransition
  }) : super(key: key);

  final ShellComponents? hiddenComponents;

  final ShellComponents visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  Animation<double> get _peekAnimation => CurvedAnimation(
        parent: animation,
        // Animate during the final third of the animation
        curve: const Interval(0.66, 1.0)
      ).drive(kPeekTween);

  Animation<double> get _position {
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
        if (visibleComponents.optionsHandle != null) {
          return kAlwaysPeekAnimation;
        } else {
          return kAlwaysDismissedAnimation;
        }
      case _LayersTransition.idleAtOptions:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        if (visibleComponents.optionsHandle != null) {
          return _peekAnimation;
        } else {
          return kAlwaysDismissedAnimation;
        }
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
        assert(hiddenComponents != null);
        if (hiddenComponents!.optionsHandle != null) {
          if (visibleComponents.optionsHandle != null) {
            return kAlwaysPeekAnimation;
          } else {
            return ReverseAnimation(_peekAnimation);
          }
        } else if (visibleComponents.optionsHandle != null) {
          return _peekAnimation;
        } else {
          return kAlwaysDismissedAnimation;
        }
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return animation.drive(kExpandTween);
    }
  }

  Animation<double> get _handleOpacity {
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtRoute:
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseRoute:
      case _LayersTransition.expandOrCollapseRoute:
        return kAlwaysCompleteAnimation;
      case _LayersTransition.idleAtOptions:
        return kAlwaysDismissedAnimation;
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
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
        return kAlwaysCompleteAnimation;
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        return animation;
      default:
        return kAlwaysDismissedAnimation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final handleOpacity = _handleOpacity;
    return SheetWithHandle(
      animation: _position,
      handle: Stack(
        children: <Widget>[
          FadeTransition(
            opacity: ReverseAnimation(handleOpacity),
            child: hiddenComponents?.optionsHandle),
          FadeTransition(
            opacity: handleOpacity,
            child: visibleComponents.optionsHandle)
        ]),
      body: FadeTransition(
        opacity: _bodyOpacity,
        child: visibleComponents.optionsBody));
  }
}
