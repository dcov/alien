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
  pop,
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

enum PathRouterMoveTransition {
  replace,
  none,
}

class PathRouterMoveResult<R extends PathRoute> {

  PathRouterMoveResult._({
    required this.transition,
    required this.stack
  });

  final PathRouterMoveTransition transition;

  final List<R> stack;
}

class PathRouter<R extends PathRoute> {

  late final nodes = UnmodifiableMapView<String, PathNode<R>>(_nodes);
  final _nodes = <String, PathNode<R>>{};
  var _stack = <String>[];

  PathRouterGoToResult<R> goTo(
      String path, {
      required PathRouteFactory<R> onCreateRoute,
      required PathRouteUpdateCallback<R> onUpdateRoute,
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
      final isInOldStack = (i < oldStack.length && oldStack[i] == fragment);

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

        if (parentsAreInOldStack) {
          if (oldStack.length == newStack.length - 1) {
            // onPushRoute(newRoute);
          } else {
            // onReplaceStack(stack);
          }
        } else {
          // onReplaceStack(stack);
        }
      } else if (isLastFragment) {
        assert(node.route.fragment == fragment);
        assert(node.route.path == path);
        onUpdateRoute(node.route);
        // Check if the new stack matches the new stack up to this point, in which case it might be
        // the exact same stack, a popped route (that isn't removed from the tree), or just a replace.
        if (parentsAreInOldStack && isInOldStack) {
          if (oldStack.length == newStack.length) {
            // The Stack did not change
            // onSameStack();
          } else if (newStack.length == oldStack.length - 1) {
            // The stack was popped
            // onPopRoute();
          } else {
            // The stack was popped more than one route so we'll treat it as a replace
            // onReplaceStack(stack);
          }
        } else {
          // The parents aren't the same, or this route isn't the same so it's a replace.
          // onReplaceStack(stack);
        }
      } else {
        parentNode = node;
        parentsAreInOldStack = (parentsAreInOldStack && isInOldStack);
      }
    }

    return PathRouterGoToResult._(transition: PathRouterGoToTransition.none, stack: <R>[]);
  }

  void pop(
      String path, {
      required 
    }) {
    // TODO
  }

  void move(
      String fromPath,
      String toPath
    ) {
    // TODO
  }
}
