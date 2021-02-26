import 'package:flutter_test/flutter_test.dart';
import 'package:alien/utils/path_router.dart';

class _TestRoute extends PathRoute {

  _TestRoute(this.name);

  final String name;

  @override
  String toString() => name;
}

PathRouteFactory<_TestRoute> _factory(String name) {
  return () => _TestRoute(name);
}

_TestRoute _errorFactory() {
  throw StateError('_errorFactory does not expect to be called.');
}

String _fragmentsListString(List<_TestRoute> stack) {
  return stack.map((route) => route.fragment).toList().toString();
}

String _nodesString(Map<String, PathNode<_TestRoute>> nodes) {
  return nodes.map<String, String>((String key, PathNode<_TestRoute> value) {
    return MapEntry<String, String>(key, _nodesString(value.children));
  }).toString();
}

void testPathRouter() {
  group('PathRouter', () {
    test('goTo', () {
      final router = PathRouter<_TestRoute>();
      var result = router.goTo('a0', onCreateRoute: _factory('a0'));
      expect(result.transition, PathRouterGoToTransition.pushFromEmpty);
      expect(result.stack.toString(), ['a0'].toString());
      expect(_nodesString(router.nodes), {'a0': {}}.toString());

      result = router.goTo('a0/a1', onCreateRoute: _factory('a1'));
      expect(result.transition, PathRouterGoToTransition.push);
      expect(result.stack.toString(), ['a0', 'a1'].toString());
      expect(_nodesString(router.nodes), {'a0': { 'a1': {}}}.toString());

      result = router.goTo('a0', onCreateRoute: _errorFactory);
      expect(result.transition, PathRouterGoToTransition.goBack);
      expect(result.stack.toString(), ['a0'].toString());
      expect(_nodesString(router.nodes), {'a0': { 'a1': {}}}.toString());

      result = router.goTo('b0', onCreateRoute: _factory('b0'));
      expect(result.transition, PathRouterGoToTransition.replace);
      expect(result.stack.toString(), ['b0'].toString());
      expect(_nodesString(router.nodes),
          {'a0': { 'a1': {}},
           'b0': {}}.toString());

      result = router.goTo('b0/b1', onCreateRoute: _factory('b1'));
      expect(result.transition, PathRouterGoToTransition.push);
      expect(result.stack.toString(), ['b0', 'b1'].toString());
      expect(_nodesString(router.nodes),
          {'a0': { 'a1': {}},
           'b0': { 'b1': {}}}.toString());

      result = router.goTo('a0/a1', onCreateRoute: _errorFactory);
      expect(result.transition, PathRouterGoToTransition.replace);
      expect(result.stack.toString(), ['a0', 'a1'].toString());
      expect(_nodesString(router.nodes),
          {'a0': { 'a1': {}},
           'b0': { 'b1': {}}}.toString());

      result = router.goTo('a0/a1', onCreateRoute: _errorFactory);
      expect(result.transition, PathRouterGoToTransition.none);
      expect(result.stack.toString(), ['a0', 'a1'].toString());
      expect(_nodesString(router.nodes),
          {'a0': { 'a1': {}},
           'b0': { 'b1': {}}}.toString());

      expect(() => router.goTo('c0/c1', onCreateRoute: _errorFactory), throwsAssertionError);
      expect(_nodesString(router.nodes),
          {'a0': { 'a1': {}},
           'b0': { 'b1': {}}}.toString());
    });

    test('remove', () {
      final router = PathRouter<_TestRoute>();
        // add the 'a0' route
      router.goTo('a0', onCreateRoute: _factory('a0'));
      expect(_nodesString(router.nodes), {'a0': {}}.toString());

      var result = router.remove('a0');
      expect(result.transition, PathRouterRemoveTransition.popToEmpty);
      expect(result.stack.toString(), [].toString());
      expect(_nodesString(router.nodes), {}.toString());

      router.goTo('a0', onCreateRoute: _factory('a0'));
      router.goTo('a0/a1', onCreateRoute: _factory('a1'));
      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'));
      expect(_nodesString(router.nodes), {'a0': { 'a1': { 'a2': {}}}}.toString());

      result = router.remove('a0/a1/a2');
      expect(result.transition, PathRouterRemoveTransition.pop);
      expect(result.stack.toString(), ['a0', 'a1'].toString());
      expect(_nodesString(router.nodes), {'a0': { 'a1': {}}}.toString());

      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'));
      expect(_nodesString(router.nodes), {'a0': { 'a1': { 'a2': {}}}}.toString());
      
      result = router.remove('a0/a1');
      expect(result.transition, PathRouterRemoveTransition.replace);
      expect(result.stack.toString(), ['a0'].toString());
      expect(_nodesString(router.nodes), {'a0': {}}.toString());

      router.goTo('a0/a1', onCreateRoute: _factory('a1'));
      router.goTo('a0/b1', onCreateRoute: _factory('b1'));
      expect(_nodesString(router.nodes), {'a0': { 'a1': {}, 'b1': {}}}.toString());

      result = router.remove('a0/a1');
      expect(result.transition, PathRouterRemoveTransition.none);
      expect(result.stack.toString(), ['a0', 'b1'].toString());
      expect(_nodesString(router.nodes), {'a0': { 'b1': {}}}.toString());
    });

    test('detach', () {
      final router = PathRouter<_TestRoute>();

      router.goTo('a0', onCreateRoute: _factory('a0'));
      router.goTo('a0/a1', onCreateRoute: _factory('a1'));
      expect(_nodesString(router.nodes), {'a0': { 'a1': {}}}.toString());

      var result = router.detach('a0/a1', 'b0');
      expect(_fragmentsListString(result.stack), ['b0'].toString());
      expect(_nodesString(router.nodes), {'a0': {}, 'b0': {}}.toString());

      router.goTo('a0/a1', onCreateRoute: _factory('a1'));
      router.goTo('a0/a1/a2', onCreateRoute: _factory('a2'));
      router.goTo('a0/a1/a2/a3', onCreateRoute: _factory('a3'));
      expect(_nodesString(router.nodes), {'a0': { 'a1': { 'a2': { 'a3': {}}}}, 'b0': {}}.toString());

      result = router.detach('a0/a1', 'c0');
      expect(_fragmentsListString(result.stack), ['c0', 'a2', 'a3'].toString());
      expect(_nodesString(router.nodes),
          {'a0': {},
           'b0': {},
           'c0': { 'a2': { 'a3': {}}}}.toString());

      router.goTo('a0', onCreateRoute: _errorFactory);
      expect(_nodesString(router.nodes),
          {'a0': {},
           'b0': {},
           'c0': { 'a2': { 'a3': {}}}}.toString());

      result = router.detach('a0', 'd0');
      expect(_fragmentsListString(result.stack), ['d0'].toString());
      expect(_nodesString(router.nodes),
          {'b0': {},
           'c0': { 'a2': { 'a3': {}}},
           'd0': {}}.toString());
    });
  });
}
