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

  late final children = UnmodifiableMapView<String, PathNode<R>>(_children);
  final _children = <String, PathNode<R>>{};
}

enum PathRouterGoToTransition {
  pushFromEmpty,
  push,
  goBack,
  replace,
  none,
}

class PathRouterGoToResult<R extends PathRoute> {

  PathRouterGoToResult._({
    required this.transition,
    required this.stack,
  });

  final PathRouterGoToTransition transition;

  final List<R> stack;
}

enum PathRouterRemoveTransition {
  popToEmpty,
  pop,
  replace,
  none,
}

class PathRouterRemoveResult<R extends PathRoute> {

  PathRouterRemoveResult._({
    required this.transition,
    required this.stack
  });

  final PathRouterRemoveTransition transition;

  final List<R> stack;
}

class PathRouterDetachResult<R extends PathRoute> {

  PathRouterDetachResult._({
    required this.stack
  });

  final List<R> stack;
}

class PathRouter<R extends PathRoute> {

  late final UnmodifiableMapView<String, PathNode<R>> nodes = UnmodifiableMapView<String, PathNode<R>>(_nodes);
  final _nodes = <String, PathNode<R>>{};
  var _stack = <String>[];

  List<R> _buildRouteStack() {
    final result = <R>[];
    PathNode<R>? parentNode;
    for (var i = 0; i < _stack.length; i++) {
      final node = parentNode != null ? parentNode._children[_stack[i]]! : _nodes[_stack[i]]!;
      result.add(node.route);
      parentNode = node;
    }
    return result;
  }

  PathRouterGoToResult<R> goTo(
      String path, {
      required PathRouteFactory<R> onCreateRoute,
      PathRouteUpdateCallback<R>? onUpdateRoute,
    }) {
    final oldStack = _stack;
    final newStack = path.split("/");
    assert(newStack.isNotEmpty);
    _stack = newStack;

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

    return PathRouterGoToResult._(
      transition: transition,
      stack: _buildRouteStack());
  }

  PathRouterRemoveResult<R> remove(String path) {
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
      final isInStack = (i < _stack.length && _stack[i] == fragment && parentsAreInStack);

      if (isLastFragment) {
        assert(node.route.fragment == fragment);
        assert(node.route.path == path);
        // The node does not have a 
        node.route.._fragment = null
                  .._path = null;

        if (i == 0 && isInStack) {
          _nodes.remove(fragment);
          _stack.clear();
          transition =  PathRouterRemoveTransition.popToEmpty;
        } else {
          parentNode!._children.remove(fragment);
          if (parentsAreInStack && isInStack) {
            if (isInStack && _stack.length == fragments.length) {
              _stack.removeLast();
              transition = PathRouterRemoveTransition.pop;
            } else {
              _stack.removeRange(i, _stack.length);
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

    return PathRouterRemoveResult._(
      transition: transition,
      stack: _buildRouteStack());
  }

  PathRouterDetachResult<R> detach(String path, String newFragment) {
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
      final isInStack = (i < _stack.length && _stack[i] == fragment && parentsAreInStack);

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
            _stack[0] = newFragment;
          }
        } else {
          assert(parentNode._children[fragment] == node);
          parentNode._children.remove(fragment);
          _nodes[newFragment] = node;
          if (isInStack) {
            _stack = _stack.sublist(i);
            _stack[0] = newFragment;
          }
        }
      } else {
        parentNode = node;
        parentsAreInStack = (parentsAreInStack && isInStack);
      }
    }

    return PathRouterDetachResult._(
      stack: _buildRouteStack());
  }

  void _updateChildrenPaths(Map<String, PathNode> children, String updatePath(String oldPath)) {
    for (final child in children.values) {
      child.route._path = updatePath(child.route.path);
      if (child.children.isNotEmpty)
        _updateChildrenPaths(child.children, updatePath);
    }
  }
}
