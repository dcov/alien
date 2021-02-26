import 'dart:collection';

typedef PathRouteFactory<R extends PathRoute> = R Function();

typedef PathRouteUpdateCallback<R extends PathRoute> = void Function(R route);

abstract class PathRoute {

  String get fragment => _fragment!;
  String? _fragment;

  String get path => _path!;
  String? _path;
}

class PathNode<R extends PathRoute> {

  PathNode(this.route);

  final R route;

  String get path => route.path;

  late final Map<String, PathNode<R>> children = UnmodifiableMapView<String, PathNode<R>>(_children);
  final _children = <String, PathNode<R>>{};
}

enum PathRouterGoToTransition {
  pushFromEmpty,
  push,
  goBack,
  replace,
  none,
}

enum PathRouterRemoveTransition {
  popToEmpty,
  pop,
  replace,
  none,
}

class PathRouter<R extends PathRoute> {

  late final Map<String, PathNode<R>> nodes = UnmodifiableMapView<String, PathNode<R>>(_nodes);
  final _nodes = <String, PathNode<R>>{};

  List<R> get stack => UnmodifiableListView<R>(_routeStack);
  var _routeStack = <R>[];

  var _pathStack = <String>[];

  void _rebuildRouteStack() {
    final result = <R>[];
    PathNode<R>? parentNode;
    for (var i = 0; i < _pathStack.length; i++) {
      final node = parentNode != null ? parentNode._children[_pathStack[i]]! : _nodes[_pathStack[i]]!;
      result.add(node.route);
      parentNode = node;
    }
    _routeStack = result;
  }

  PathRouterGoToTransition goTo(
      String path, {
      required PathRouteFactory<R> onCreateRoute,
      PathRouteUpdateCallback<R>? onUpdateRoute,
    }) {
    final oldStack = _pathStack;
    final newStack = path.split("/");
    assert(newStack.isNotEmpty);
    _pathStack = newStack;

    late PathRouterGoToTransition transition;

    PathNode<R>? parentNode;
    bool parentsAreInOldStack = true;
    for (var i = 0; i < newStack.length; i++) {
      final fragment = newStack[i];

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

        final newRoute = onCreateRoute();
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
            transition = PathRouterGoToTransition.pushFromEmpty;
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
            transition =  PathRouterGoToTransition.none;
          } else if (newStack.length == oldStack.length - 1) {
            // The stack was popped, but since this was a call to goTo and not remove, the route
            // is not removed and instead we just 'go back' to the parent.
            transition = PathRouterGoToTransition.goBack;
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

    _rebuildRouteStack();
    return transition;
  }

  PathRouterRemoveTransition remove(String path) {
    final fragments = path.split("/");

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
        // The node does not have a 
        node.route.._fragment = null
                  .._path = null;

        if (i == 0 && isInStack) {
          _nodes.remove(fragment);
          _pathStack.clear();
          transition =  PathRouterRemoveTransition.popToEmpty;
        } else {
          parentNode!._children.remove(fragment);
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
      } else {
        parentNode = node;
        parentsAreInStack = (parentsAreInStack && isInStack);
      }
    }

    _rebuildRouteStack();
    return transition;
  }

  void detach(String path, String newFragment) {
    final fragments = path.split('/');

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
          }
        } else {
          assert(parentNode._children[fragment] == node);
          parentNode._children.remove(fragment);
          _nodes[newFragment] = node;
          if (isInStack) {
            _pathStack = _pathStack.sublist(i);
            _pathStack[0] = newFragment;
          }
        }
      } else {
        parentNode = node;
        parentsAreInStack = (parentsAreInStack && isInStack);
      }
    }

    _rebuildRouteStack();
  }

  void _updateChildrenPaths(Map<String, PathNode> children, String updatePath(String oldPath)) {
    for (final child in children.values) {
      child.route._path = updatePath(child.route.path);
      if (child.children.isNotEmpty)
        _updateChildrenPaths(child.children, updatePath);
    }
  }
}
