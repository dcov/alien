import 'package:flutter_test/flutter_test.dart';
import 'package:alien/utils/path_router.dart';

class _TestRoute extends PathRoute {

  _TestRoute(this.name);

  final String name;

  @override
  String toString() => name;
}

void _voidUpdate(_) { }

PathRouteFactory<_TestRoute> _factoryFor(String name) {
  return () => _TestRoute(name);
}

final PathRouteFactory<_TestRoute> _errorFactory = () {
  throw StateError('_errorFactory does not expect to be called.');
};

void testPathRouter() {
  group('PathRouter', () {
    group('goTo', () {
      final router = PathRouter<_TestRoute>();
      test('pushFromEmpty', () {
        final result = router.goTo(
          'a:0',
          onCreateRoute: _factoryFor('a:0'),
          onUpdateRoute: _voidUpdate);
        expect(result.transition, PathRouterGoToTransition.pushFromEmpty);
        expect(result.stack.toString(), ['a:0'].toString());
      });
      test('push', () {
        final result = router.goTo(
          'a:0/a:1',
          onCreateRoute: _factoryFor('a:1'),
          onUpdateRoute: _voidUpdate);
        expect(result.transition, PathRouterGoToTransition.push);
        expect(result.stack.toString(), ['a:0', 'a:1'].toString());
      });
      test('pop', () {
        final result = router.goTo(
          'a:0',
          onCreateRoute: _errorFactory,
          onUpdateRoute: _voidUpdate);
        expect(result.transition, PathRouterGoToTransition.pop);
        expect(result.stack.toString(), ['a:0'].toString());
      });
      test('replace', () {
        final result = router.goTo(
          'b:0',
          onCreateRoute: _factoryFor('b:0'),
          onUpdateRoute: _voidUpdate);
        expect(result.transition, PathRouterGoToTransition.replace);
        expect(result.stack.toString(), ['b:0'].toString());
      });
    });
  });
}
