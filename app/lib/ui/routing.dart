import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

typedef PathRouteFactory<R extends PathRoute> = R Function();

typedef PathRouteVisitor<R extends PathRoute> = void Function(R route);

abstract class PathRoute {

  String get fragment => _fragment!;
  String? _fragment;

  String get path => _path!;
  String? _path;

  @protected
  String get childPathPrefix => '$path/';
}

class PathNode<R extends PathRoute> {

  PathNode(this.route);

  final R route;

  String get path => route.path;

  late final Map<String, PathNode<R>> children = UnmodifiableMapView<String, PathNode<R>>(_children);
  final _children = <String, PathNode<R>>{};
}

enum PathRouterGoToTransition {
  push,
  pop,
  replace,
  none,
}

enum PathRouterRemoveTransition {
  pop,
  replace,
  none,
}

enum PathRouterDetachTransition {
  replace,
  none
}

class PathRouter<R extends PathRoute> {

  late final Map<String, PathNode<R>> nodes = UnmodifiableMapView<String, PathNode<R>>(_nodes);
  final _nodes = <String, PathNode<R>>{};

  late final List<R> stack = UnmodifiableListView<R>(_routeStack);
  final _routeStack = <R>[];

  var _pathStack = <String>[];

  void _rebuildRouteStack() {
    _routeStack.clear();
    PathNode<R>? parentNode;
    for (var i = 0; i < _pathStack.length; i++) {
      final node = parentNode != null ? parentNode._children[_pathStack[i]]! : _nodes[_pathStack[i]]!;
      _routeStack.add(node.route);
      parentNode = node;
    }
  }

  List<String> _splitAndNormalize(String path) {
    final stack = path.split('/');
    if (stack.first.isEmpty) {
      assert(stack.length == 1);
      stack.clear();
    }
    return stack;
  }

  PathRouterGoToTransition goTo(
      String path, {
      PathRouteFactory<R>? onCreateRoute,
      PathRouteVisitor<R>? onUpdateRoute,
    }) {
    final oldStack = _pathStack;
    final newStack = _splitAndNormalize(path);
    _pathStack = newStack;

    late PathRouterGoToTransition transition;

    if (newStack.isEmpty) {
      if (oldStack.isEmpty) {
        transition = PathRouterGoToTransition.none;
      } else if (oldStack.length == 1) {
        transition = PathRouterGoToTransition.pop;
      } else {
        transition = PathRouterGoToTransition.replace;
      }
    } else {
      PathNode<R>? parentNode;
      bool parentsAreInOldStack = true;
      for (var i = 0; i < newStack.length; i++) {
        final fragment = newStack[i];
        assert(fragment.isNotEmpty);

        PathNode<R>? node;
        if (parentNode == null) {
          node = _nodes[fragment];
        } else {
          node = parentNode._children[fragment];
        }

        final isLastFragment = (i == (newStack.length - 1));
        final isInOldStack = (i < oldStack.length && oldStack[i] == fragment && parentsAreInOldStack);

        if (node == null) {
          // This should be the last fragment in the path
          assert(isLastFragment,
              '$fragment is a parent in $path but it does not exist.');
          assert(onCreateRoute != null,
              'Had to create route for $path but onCreateRoute was not provided.');

          final newRoute = onCreateRoute!();
          newRoute.._fragment = fragment
                  .._path = path;

          final newNode = PathNode(newRoute);
          if (parentNode == null) {
            _nodes[fragment] = newNode;
          } else {
            parentNode._children[fragment] = newNode;
          }

          if (oldStack.isEmpty) {
            if (newStack.length == 1) {
              transition = PathRouterGoToTransition.push;
            } else {
              transition = PathRouterGoToTransition.replace;
            }
          } else if (parentsAreInOldStack) {
            if (oldStack.length == newStack.length - 1) {
              transition = PathRouterGoToTransition.push;
            } else {
              transition = PathRouterGoToTransition.replace;
            }
          } else {
            transition = PathRouterGoToTransition.replace;
          }
        } else if (isLastFragment) {
          assert(node.route.fragment == fragment);
          assert(node.route.path == path);
          if (onUpdateRoute != null) {
            onUpdateRoute(node.route);
          }
          // Check if the new stack matches the new stack up to this point, in which case it might be
          // the exact same stack, a popped route (that isn't removed from the tree), or just a replace.
          if (parentsAreInOldStack && isInOldStack) {
            if (oldStack.length == newStack.length) {
              // The Stack did not change
              transition = PathRouterGoToTransition.none;
            } else if (newStack.length == oldStack.length - 1) {
              // The stack was popped, but since this was a call to goTo and not remove, the route
              // is not removed and instead we just 'go back' to the parent.
              transition = PathRouterGoToTransition.pop;
            } else {
              // The stack was popped more than one route so we'll treat it as a replace
              transition = PathRouterGoToTransition.replace;
            }
          } else {
            // The parents aren't the same, or this route isn't the same so it's a replace.
            transition = PathRouterGoToTransition.replace;
          }
        } else {
          parentNode = node;
          parentsAreInOldStack = (parentsAreInOldStack && isInOldStack);
        }
      }
    }

    if (transition != PathRouterGoToTransition.none) {
      _rebuildRouteStack();
    }

    return transition;
  }

  PathRouterRemoveTransition remove(String path, { PathRouteVisitor<R>? onRemovedRoute }) {
    final fragments = _splitAndNormalize(path);

    late PathRouterRemoveTransition transition;

    PathNode<R>? parentNode;
    bool parentsAreInStack = true;
    for (var i = 0; i < fragments.length; i++) {
      final fragment = fragments[i];

      final PathNode<R> node;
      if (parentNode == null) {
        node = _nodes[fragment]!;
      } else {
        node = parentNode._children[fragment]!;
      }

      final isLastFragment = (i == fragments.length - 1);
      final isInStack = (i < _pathStack.length && _pathStack[i] == fragment && parentsAreInStack);

      if (isLastFragment) {
        assert(node.route.fragment == fragment);
        assert(node.route.path == path);

        PathNode<R> removedNode;
        if (i == 0) {
          removedNode = _nodes.remove(fragment)!;
          if (isInStack) {
            _pathStack.clear();
            transition = PathRouterRemoveTransition.pop;
          } else {
            transition = PathRouterRemoveTransition.none;
          }
        } else {
          removedNode = parentNode!._children.remove(fragment)!;
          if (parentsAreInStack && isInStack) {
            if (isInStack && _pathStack.length == fragments.length) {
              _pathStack.removeLast();
              transition = PathRouterRemoveTransition.pop;
            } else {
              _pathStack.removeRange(i, _pathStack.length);
              transition = PathRouterRemoveTransition.replace;
            }
          } else {
            // We removed a subtree that was not in the stack
            transition = PathRouterRemoveTransition.none;
          }
        }

        if (onRemovedRoute != null)
          _visitNodes(removedNode, onRemovedRoute);
      } else {
        parentNode = node;
        parentsAreInStack = (parentsAreInStack && isInStack);
      }
    }

    if (transition != PathRouterRemoveTransition.none)
      _rebuildRouteStack();

    return transition;
  }

  void _visitNodes(PathNode<R> node, PathRouteVisitor<R> visitor) {
    visitor(node.route);
    node.children.values.forEach((node) => _visitNodes(node, visitor));
  }

  PathRouterDetachTransition detach(String path, String newFragment) {
    final fragments = _splitAndNormalize(path);

    late PathRouterDetachTransition transition;

    PathNode<R>? parentNode;
    bool parentsAreInStack = true;
    for (var i = 0; i < fragments.length; i++) {
      final fragment = fragments[i];

      final PathNode<R> node;
      if (parentNode == null) {
        node = _nodes[fragment]!;
      } else {
        node = parentNode._children[fragment]!;
      }

      final isLastFragment = (i == fragments.length - 1);
      final isInStack = (i < _pathStack.length && _pathStack[i] == fragment && parentsAreInStack);

      if (isLastFragment) {
        assert(node.route.fragment == fragment);
        assert(node.route.path == path);

        node.route.._fragment = newFragment;
        node.route.._path = newFragment;

        if (node.children.isNotEmpty) {
          _updateChildrenPaths(node.children, (String oldPath) {
            final fragments = oldPath.split('/');
            final newFragments = fragments.sublist(i);
            newFragments[0] = newFragment;
            return newFragments.join('/');
          });
        }

        if (parentNode == null) {
          assert(_nodes[fragment] == node);
          _nodes.remove(fragment);
          _nodes[newFragment] = node;
          if (isInStack) {
            _pathStack[0] = newFragment;
            transition = PathRouterDetachTransition.replace;
          } else {
            transition = PathRouterDetachTransition.none;
          }
        } else {
          assert(parentNode._children[fragment] == node);
          parentNode._children.remove(fragment);
          _nodes[newFragment] = node;
          if (isInStack) {
            _pathStack = _pathStack.sublist(i);
            _pathStack[0] = newFragment;
            transition = PathRouterDetachTransition.replace;
          } else {
            transition = PathRouterDetachTransition.none;
          }
        }
      } else {
        parentNode = node;
        parentsAreInStack = (parentsAreInStack && isInStack);
      }
    }

    if (transition != PathRouterDetachTransition.none)
      _rebuildRouteStack();

    return transition;
  }

  void _updateChildrenPaths(Map<String, PathNode> children, String updatePath(String oldPath)) {
    for (final child in children.values) {
      child.route._path = updatePath(child.route.path);
      if (child.children.isNotEmpty)
        _updateChildrenPaths(child.children, updatePath);
    }
  }
}

mixin _Route {

  void initState(BuildContext context) { }

  void didChangeDependencies(BuildContext context) { }

  void dispose(BuildContext context) { }

  Widget build(BuildContext context);
}

abstract class RootRoute with _Route { }

abstract class ChildRoute extends PathRoute with _Route { }

final _kPrimaryTween = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero);

final _kSecondaryTween = Tween<Offset>(begin: Offset.zero, end: Offset(-(1.0/3.0), 0.0));

class _RoutePage extends Page {

  _RoutePage({
    required this.route
  });

  final _Route route;

  Widget _buildPage(BuildContext context, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
    return SlideTransition(
      position: primaryAnimation.drive(_kPrimaryTween),
      child: SlideTransition(
        position: secondaryAnimation.drive(_kSecondaryTween),
        child: route.build(context)));
  }

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: _buildPage);
  }
}

class Routing extends StatefulWidget {

  Routing({
    Key? key,
    required this.root
  }) : super(key: key);

  final RootRoute root;

  @override
  _RoutingState createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: <Page>[
      ]);
  }
}
