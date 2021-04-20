import 'package:flutter_test/flutter_test.dart';
import 'package:alien/ui/path_router.dart';

class _TestRoute extends PathRoute {

  _TestRoute(this.name);

  final String name;

  @override
  String toString() => name;
}

PathRouteFactory<_TestRoute> _factory(String name) {
  return () => _TestRoute(name);
}

typedef _UpdateCallback = int Function([_TestRoute? route]);

_UpdateCallback _update() {
  int count = 0;
  return ([_]) {
    return count++;
  };
}

_TestRoute _errorFactory() {
  throw StateError('_errorFactory does not expect to be called.');
}

_TestRoute _errorUpdate(_) {
  throw StateError('_errorUpdate does not expect to be called');
}

PathRouteVisitor<_TestRoute> _removedAggregator(Set<String> aggregate) {
  final pathAggregate = <String>{};
  return (route) {
    if (pathAggregate.contains(route.path))
        throw StateError('${route.path} has already been called as removed');
    pathAggregate.add(route.path);
    aggregate.add(route.name);
  };
}

List<String> _stack(List<_TestRoute> stack) {
  return stack.map((route) => route.fragment).toList();
}

Map _nodes(Map<String, PathNode<_TestRoute>> nodes) {
  void convert(Map<String, PathNode<_TestRoute>> from, Map into) {
    for (final entry in from.entries) {
      into[entry.key] = Map();
      if (entry.value.children.isNotEmpty) {
        convert(entry.value.children, into[entry.key]!);
      }
    }
  }
  final result = Map();
  convert(nodes, result);
  return result;
}

void testPathRouter() {
  group('PathRouter', () {
    test('goTo first path', () {
      final router = PathRouter<_TestRoute>();
      final transition = router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      expect(transition, equals(PathRouterGoToTransition.push));
      expect(_stack(router.stack), equals(['a0']));
      expect(_nodes(router.nodes), equals({'a0': {}}));
      expect(router.stack.first.path, equals('a0'));
    });

    test('goTo new child path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      final transition = router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      expect(transition, equals(PathRouterGoToTransition.push));
      expect(_stack(router.stack), equals(['a0', 'a1']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}}));
    });

    test('goTo previous path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      final updateCount = _update();
      final transition = router.goTo('a0', onCreateRoute: _errorFactory, onUpdateRoute: updateCount);
      expect(transition, equals(PathRouterGoToTransition.pop));
      expect(_stack(router.stack), equals(['a0']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}}));
      expect(updateCount(), equals(1));
    });

    test('goTo unrelated path from exisiting path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      final transition = router.goTo('b0', onCreateRoute: _factory('b0'), onUpdateRoute: _errorUpdate);
      expect(transition, equals(PathRouterGoToTransition.replace));
      expect(_stack(router.stack), equals(['b0']));
      expect(_nodes(router.nodes), equals({'a0': {}, 'b0': {}}));
    });

    test('goTo new child path when there are unrelated path trees', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('b0', onCreateRoute: _factory('b0'), onUpdateRoute: _errorUpdate);
      final transition = router.goTo('b0/b1', onCreateRoute: _factory('b1'), onUpdateRoute: _errorUpdate);
      expect(transition, equals(PathRouterGoToTransition.push));
      expect(_stack(router.stack), equals(['b0', 'b1']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}, 'b0': { 'b1': {}}}));
    });

    test('goTo unrelated path tree from existing path tree', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('b0', onCreateRoute: _factory('b0'), onUpdateRoute: _errorUpdate);
      router.goTo('b0/b1', onCreateRoute: _factory('b1'), onUpdateRoute: _errorUpdate);
      final update = _update();
      final transition = router.goTo('a0/a1', onCreateRoute: _errorFactory, onUpdateRoute: update);
      expect(transition, equals(PathRouterGoToTransition.replace));
      expect(_stack(router.stack), equals(['a0', 'a1']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}, 'b0': { 'b1': {}}}));
      expect(update(), equals(1));
    });

    test('goTo existing path tree', () { 
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      final update = _update();
      final transition = router.goTo('a0/a1', onCreateRoute: _errorFactory, onUpdateRoute: update);
      expect(transition, equals(PathRouterGoToTransition.none));
      expect(_stack(router.stack), equals(['a0', 'a1']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}}));
      expect(update(), equals(1));

    });

    test('goTo empty path from existing path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      final transition = router.goTo('', onCreateRoute: _errorFactory, onUpdateRoute: _errorUpdate);
      expect(transition, equals(PathRouterGoToTransition.pop));
      expect(_stack(router.stack), equals([]));
      expect(_nodes(router.nodes), equals({'a0': {}}));
    });

    test('goTo existing path from empty path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('', onCreateRoute: _errorFactory, onUpdateRoute: _errorUpdate);
      final update = _update();
      final transition = router.goTo('a0', onCreateRoute: _errorFactory, onUpdateRoute: update);
      expect(transition, equals(PathRouterGoToTransition.replace));
      expect(_stack(router.stack), equals(['a0']));
      expect(_nodes(router.nodes), equals({'a0': {}}));
      expect(update(), equals(1));
    });

    test('goTo path with non existing parents', () {
      final router = PathRouter<_TestRoute>();
      expect(() => router.goTo('a0/a1', onCreateRoute: _errorFactory, onUpdateRoute: _errorUpdate), throwsAssertionError);
      expect(_stack(router.stack), equals([]));
      expect(_nodes(router.nodes), equals({}));
    });

    test('remove first path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute:  _errorUpdate);
      final removed = <String>{};
      final transition = router.remove('a0', onRemovedRoute: _removedAggregator(removed));
      expect(transition, equals(PathRouterRemoveTransition.pop));
      expect(_stack(router.stack), equals([]));
      expect(_nodes(router.nodes), equals({}));
      expect(removed, equals({'a0'}));
    });

    test('remove leaf path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'), onUpdateRoute: _errorUpdate);
      final removed = <String>{};
      final transition = router.remove('a0/a1/a2', onRemovedRoute: _removedAggregator(removed));
      expect(transition, equals(PathRouterRemoveTransition.pop));
      expect(_stack(router.stack), equals(['a0', 'a1']));
      expect(_nodes(router.nodes), equals({'a0': { 'a1': {}}}));
      expect(removed, equals({'a2'}));
    });

    test('remove path with children', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'), onUpdateRoute: _errorUpdate);
      final removed = <String>{};
      final transition = router.remove('a0/a1', onRemovedRoute: _removedAggregator(removed));
      expect(transition, equals(PathRouterRemoveTransition.replace));
      expect(_stack(router.stack), equals(['a0']));
      expect(_nodes(router.nodes), equals({'a0': {}}));
      expect(removed, equals({'a1', 'a2'}));
    });

    test('remove sibling of current path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/b1', onCreateRoute: _factory('b1'), onUpdateRoute: _errorUpdate);
      final removed = <String>{};
      final transition = router.remove('a0/a1', onRemovedRoute: _removedAggregator(removed));
      expect(transition, equals(PathRouterRemoveTransition.none));
      expect(_stack(router.stack), equals(['a0', 'b1']));
      expect(_nodes(router.nodes), equals({'a0': { 'b1': {}}}));
      expect(removed, equals({'a1'}));
    });

    test('remove unrelated path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('b0', onCreateRoute: _factory('b0'), onUpdateRoute: _errorUpdate);
      final removed = <String>{};
      final transition = router.remove('a0', onRemovedRoute: _removedAggregator(removed));
      expect(transition, equals(PathRouterRemoveTransition.none));
      expect(_stack(router.stack), equals(['b0']));
      expect(_nodes(router.nodes), equals({'b0': {}}));
      expect(removed, equals({'a0', 'a1'}));
    });

    test('detach only path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      final transition = router.detach('a0', 'b0');
      expect(transition, equals(PathRouterDetachTransition.replace));
      expect(_stack(router.stack), equals(['b0']));
      expect(_nodes(router.nodes), equals({'b0': {}}));
    });

    test('detach leaf path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      var transition = router.detach('a0/a1', 'b0');
      expect(transition, equals(PathRouterDetachTransition.replace));
      expect(_stack(router.stack), equals(['b0']));
      expect(_nodes(router.nodes), equals({'a0': {}, 'b0': {}}));
    });

    test('detach path tree', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1', onCreateRoute: _factory('a1'), onUpdateRoute: _errorUpdate);
      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'), onUpdateRoute: _errorUpdate);
      final transition = router.detach('a0/a1', 'b0');
      expect(transition, equals(PathRouterDetachTransition.replace));
      expect(_stack(router.stack), equals(['b0', 'a2']));
      expect(_nodes(router.nodes), equals({'a0': {}, 'b0': { 'a2': {}}}));
    });

    test('detach unrelated path', () {
      final router = PathRouter<_TestRoute>();
      router.goTo('a0', onCreateRoute: _factory('a0'), onUpdateRoute: _errorUpdate);
      router.goTo('b0', onCreateRoute: _factory('b0'), onUpdateRoute: _errorUpdate);
      final transition = router.detach('a0', 'c0');
      expect(transition, equals(PathRouterDetachTransition.none));
      expect(_stack(router.stack), equals(['b0']));
      expect(_nodes(router.nodes), equals({'b0': {}, 'c0': {}}));
    });
  });
}
