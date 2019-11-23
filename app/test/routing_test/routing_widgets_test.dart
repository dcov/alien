part of 'routing_test.dart';

class MockRouterEntry extends Mock implements TargetEntry { }

MockRouterEntry _generateMockEntry(Target target) {
  final MockRouterEntry entry = MockRouterEntry();
  when(entry.target).thenReturn(target);
  when(entry.title).thenReturn('');
  when(entry.buildTopActions(any)).thenReturn(const <Widget>[]);
  when(entry.buildBody(any)).thenReturn(const SizedBox());
  when(entry.buildBottomActions(any)).thenReturn(const <Widget>[]);
  return entry;
}

Target _generateMockTarget(int depth) {
  final MockTarget target = MockTarget();
  when(target.depth).thenReturn(depth);
  return target;
}

Iterable<Target> _bodyTargets(ShellAreaState body) {
  return body.entries
      .cast<TargetEntry>()
      .map((TargetEntry entry) {
        return entry.target;
      });
}

void testRoutingWidgets() => testWidgets(
  'Routing Widgets Test',
  (WidgetTester tester) async {

    final MockRootRouting root = MockRootRouting();
    final MockRouting routing = MockRouting();
    when(root.routing).thenReturn(routing);
    final MockTarget target0 = _generateMockTarget(0);
    when(routing.tree).thenReturn(<Target>[]);
    routing.tree.add(target0);
    when(routing.current).thenReturn(target0);

    final GlobalKey<ShellAreaState> areaKey = GlobalKey<ShellAreaState>();
    final RoutingController controller = RoutingController(
      routing: routing,
      onGetArea: () => areaKey.currentState,
      onGenerateEntry: _generateMockEntry,
      onDispatchPush: (t) => TestPush(target: t).update(root),
      onDispatchPop: (t) => TestPop(target: t).update(root),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ShellArea(
          key: areaKey,
          controller: controller,
          initialEntries: controller.initialBodyEntries,
        )
      )
    );

    final ShellAreaState area = areaKey.currentState;

    expect(_bodyTargets(area), orderedEquals([target0]));

    final MockTarget target1 = _generateMockTarget(1);
    controller.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(area), orderedEquals([target0, target1]));

    final MockTarget target2 = _generateMockTarget(2);
    controller.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target1, target2]));

    controller.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0]));

    controller.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target1]));

    controller.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target1, target2]));

    controller.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(area), orderedEquals([target0, target1]));

    controller.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0]));
    expect(_bodyTargets(area), orderedEquals([target0]));

    controller.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(area), orderedEquals([target0, target1]));

    controller.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target1, target2]));

    controller.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0]));

    // We'll place this as a sibling of [target1] so it'll have a depth of 1.
    final MockTarget target3 = _generateMockTarget(1);
    controller.push(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target3);
    expect(routing.tree, orderedEquals([target0, target3, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target3]));

    final MockTarget target4 = _generateMockTarget(2);
    controller.push(target4);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target4);
    expect(routing.tree, orderedEquals([target0, target3, target4, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0, target3, target4]));

    // Pop the target below the current one
    controller.pop(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(area), orderedEquals([target0]));

    // Pop the root target
    controller.pop(target0);
    await tester.pumpAndSettle();
    // It should only remove any descendants of the root target, and not the 
    // root target itself.
    expect(routing.tree, orderedEquals([target0]));
    expect(_bodyTargets(area), orderedEquals([target0]));
  }
);

