part of 'routing_test.dart';

/// A test implementation of [PushTarget].
///
/// [PushTarget]'s functionality is implemented in its [push] method so
/// all this class does is return the result of calling it with the
/// [routing], and [target] values.
class TestPush extends PushTarget {

  const TestPush({ @required this.target });

  final Target target;

  @override
  bool update(RootRouting root) {
    return push(root.routing, target);
  }
}

/// A Test implementation of [PopTarget].
///
/// [PopTarget]'s functionality is implemented in its [pop] method so
/// all this class does is call it with the [routing], and [target] values.
class TestPop extends PopTarget {

  const TestPop({ @required this.target });

  final Target target;

  @override
  Set<Target> update(RootRouting root) {
    return pop(root.routing, target);
  }
}

void testRoutingEvents() {
  group('Routing Events Test', () {
    final MockRootRouting root = MockRootRouting();
    when(root.routing).thenReturn(MockRouting());
    final MockRouting routing = root.routing;
    final List<MockTarget> targets = <MockTarget>[
      MockTarget(),
      MockTarget(),
      MockTarget(),
      MockTarget()
    ];

    test('InitRouting Test', () {
      when(routing.tree).thenReturn(List());
      InitRouting(rootTargets: [targets[0]]).update(root);
      expect(routing.tree, orderedEquals([targets[0]]));

      verify(targets[0].depth = 0);
      when(targets[0].depth).thenReturn(0);
    });

    test('PushTarget Test', () {
      expect(TestPush(target: targets[0]).update(root), isTrue);
      verify(targets[0].active = true);
      when(targets[0].active).thenReturn(true);
      verify(routing.current = targets[0]);
      when(routing.current).thenReturn(targets[0]);

      expect(TestPush(target: targets[1]).update(root), isTrue);
      verify(targets[1].depth = 1);
      when(targets[1].depth).thenReturn(1);
      verify(targets[1].active = true);
      when(targets[1].active).thenReturn(true);
      verify(routing.current = targets[1]);
      when(routing.current).thenReturn(targets[1]);
      expect(routing.tree, orderedEquals([targets[0], targets[1]]));

      expect(TestPush(target: targets[0]).update(root), isFalse);
      verify(routing.current = targets[0]);
      when(routing.current).thenReturn(targets[0]);

      expect(TestPush(target: targets[2]).update(root), isTrue);
      verify(targets[2].depth = 1);
      when(targets[2].depth).thenReturn(1);
      verify(targets[2].active = true);
      when(targets[2].active).thenReturn(true);
      verify(routing.current = targets[2]);
      when(routing.current).thenReturn(targets[2]);
      expect(routing.tree, orderedEquals([targets[0], targets[2], targets[1]]));

      expect(TestPush(target: targets[3]).update(root), isTrue);
      verify(targets[3].depth = 2);
      when(targets[3].depth).thenReturn(2);
      verify(targets[3].active = true);
      when(targets[3].active).thenReturn(true);
      verify(routing.current = targets[3]);
      when(routing.current).thenReturn(targets[3]);
      expect(routing.tree, orderedEquals([targets[0], targets[2],
                                          targets[3], targets[1]]));
    });

    test('PopTarget Test', () {
      expect(TestPop(target: targets[1]).update(root),
          unorderedEquals([targets[1]]));
      verify(targets[1].depth = null);
      verify(targets[1].active = false);
      expect(routing.tree, orderedEquals([targets[0], targets[2], targets[3]]));

      expect(TestPop(target: targets[2]).update(root),
          unorderedEquals([targets[2], targets[3]]));
      verify(targets[2].depth = null);
      verify(targets[2].active = false);
      verify(targets[3].depth = null);
      verify(targets[3].active = false);
      verify(routing.current = targets[0]);
      when(routing.current).thenReturn(targets[0]);
      expect(routing.tree, orderedEquals([targets[0]]));

      clearInteractions(targets[0]);
      expect(TestPop(target: targets[0]).update(root), isEmpty);
      // verify that its depth wasn't changed.
      verifyNever(targets[0].depth = null);
      // verify that its status wasn't changed.
      verifyNever(targets[0].active = false);
    });
  });
}

