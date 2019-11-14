part of 'routing_test.dart';

class MockRouterEntry extends Mock implements RouterEntry { }

RouterEntry _generateMockEntry(RoutingTarget target) {
  final MockRouterEntry entry = MockRouterEntry();
  when(entry.target).thenReturn(target);
  when(entry.title).thenReturn('');
  when(entry.buildTopActions(any)).thenReturn(const <Widget>[]);
  when(entry.buildBody(any)).thenReturn(const SizedBox());
  when(entry.buildBottomActions(any)).thenReturn(const <Widget>[]);
  return entry;
}

RoutingTarget _generateMockTarget(int depth) {
  final MockRoutingTarget target = MockRoutingTarget();
  when(target.depth).thenReturn(depth);
  return target;
}

Iterable<RoutingTarget> _scaffoldTargets(CustomScaffoldState scaffold) {
  return scaffold.entries
      .cast<RouterEntry>()
      .map((RouterEntry entry) {
        return entry.target;
      });
}

void testRoutingWidgets() => testWidgets(
  'Routing Widgets Test',
  (WidgetTester tester) async {

    final MockRootRouting root = MockRootRouting();
    final MockRouting routing = MockRouting();
    when(root.routing).thenReturn(routing);
    final MockRoutingTarget target0 = _generateMockTarget(0);
    when(routing.tree).thenReturn(<RoutingTarget>[]);
    routing.tree.add(target0);
    when(routing.current).thenReturn(target0);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScaffoldConfiguration(
          barHeight: 0.0,
          barElevation: 0.0,
          bottomLeading: const SizedBox(),
          child: Router(
            routing: routing,
            onGenerateEntry: _generateMockEntry,
            onGeneratePush: (t) {
              TestPush(target: t).update(root);
              return null;
            },
            onGeneratePop: (t) {
              TestPop(target: t).update(root);
              return null;
            },
            // Dont' dispatch anything
            dispatch: (_, __) {}
          )
        )
      )
    );

    final RouterState router = tester.state(find.byType(Router));
    final CustomScaffoldState scaffold = tester.state(find.byType(CustomScaffold));

    // Router has to do setup after the initial frame; wait for that to finish.
    await tester.pumpAndSettle();
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));

    final MockRoutingTarget target1 = _generateMockTarget(1);
    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1]));

    final MockRoutingTarget target2 = _generateMockTarget(2);
    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1, target2]));

    router.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));

    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1]));

    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1, target2]));

    router.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1]));

    router.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));

    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1]));

    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target1, target2]));

    router.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));

    // We'll place this as a sibling of [target1] so it'll have a depth of 1.
    final MockRoutingTarget target3 = _generateMockTarget(1);
    router.push(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target3);
    expect(routing.tree, orderedEquals([target0, target3, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target3]));

    final MockRoutingTarget target4 = _generateMockTarget(2);
    router.push(target4);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target4);
    expect(routing.tree, orderedEquals([target0, target3, target4, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0, target3, target4]));

    // Pop the target below the current one
    router.pop(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));

    // Pop the root target
    router.pop(target0);
    await tester.pumpAndSettle();
    // It should only remove any descendants of the root target, and not the 
    // root target itself.
    expect(routing.tree, orderedEquals([target0]));
    expect(_scaffoldTargets(scaffold), orderedEquals([target0]));
  }
);

