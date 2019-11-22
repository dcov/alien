part of 'routing_test.dart';

class MockRouterEntry extends Mock implements RouterEntry { }

class TestRouter extends StatefulWidget {

  TestRouter({
    Key key,
    @required this.root,
    @required this.routing,
  }) : super(key: key);

  final RootRouting root;

  final Routing routing;

  @override
  TestRouterState createState() => TestRouterState();
} 

class TestRouterState extends State<TestRouter> with RouterMixin {

  final GlobalKey<ShellAreaState> _bodyKey = GlobalKey<ShellAreaState>();

  @override
  ShellAreaState get body => _bodyKey.currentState;

  @override
  Routing get routing => widget.routing;

  @override
  void didPush(Target target) {
    TestPush(target: target).update(widget.root);
  }

  @override
  void didPop(Target target) {
    TestPop(target: target).update(widget.root);
  }

  @override
  MockRouterEntry createEntry(Target target) {
    final MockRouterEntry entry = MockRouterEntry();
    when(entry.target).thenReturn(target);
    when(entry.title).thenReturn('');
    when(entry.buildTopActions(any)).thenReturn(const <Widget>[]);
    when(entry.buildBody(any)).thenReturn(const SizedBox());
    when(entry.buildBottomActions(any)).thenReturn(const <Widget>[]);
    return entry;
  }

  @override
  Widget build(BuildContext context) {
    return buildRouter(
      child: ShellArea(
        key: _bodyKey,
        onPop: () {},
        initialEntries: super.initialBodyEntries,
      )
    );
  }
}

Target _generateMockTarget(int depth) {
  final MockTarget target = MockTarget();
  when(target.depth).thenReturn(depth);
  return target;
}

Iterable<Target> _bodyTargets(ShellAreaState body) {
  return body.entries
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
    final MockTarget target0 = _generateMockTarget(0);
    when(routing.tree).thenReturn(<Target>[]);
    routing.tree.add(target0);
    when(routing.current).thenReturn(target0);

    await tester.pumpWidget(
      MaterialApp(
        home: TestRouter(
          root: root,
          routing: routing,
        )
      )
    );

    final TestRouterState router = tester.state(find.byType(TestRouter));
    final ShellAreaState body = tester.state(find.byType(ShellArea));

    expect(_bodyTargets(body), orderedEquals([target0]));

    final MockTarget target1 = _generateMockTarget(1);
    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(body), orderedEquals([target0, target1]));

    final MockTarget target2 = _generateMockTarget(2);
    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target1, target2]));

    router.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0]));

    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target1]));

    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target1, target2]));

    router.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(body), orderedEquals([target0, target1]));

    router.pop();
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0]));
    expect(_bodyTargets(body), orderedEquals([target0]));

    router.push(target1);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target1);
    expect(routing.tree, orderedEquals([target0, target1]));
    expect(_bodyTargets(body), orderedEquals([target0, target1]));

    router.push(target2);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target2);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target1, target2]));

    router.push(target0);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0]));

    // We'll place this as a sibling of [target1] so it'll have a depth of 1.
    final MockTarget target3 = _generateMockTarget(1);
    router.push(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target3);
    expect(routing.tree, orderedEquals([target0, target3, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target3]));

    final MockTarget target4 = _generateMockTarget(2);
    router.push(target4);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target4);
    expect(routing.tree, orderedEquals([target0, target3, target4, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0, target3, target4]));

    // Pop the target below the current one
    router.pop(target3);
    await tester.pumpAndSettle();
    when(routing.current).thenReturn(target0);
    expect(routing.tree, orderedEquals([target0, target1, target2]));
    expect(_bodyTargets(body), orderedEquals([target0]));

    // Pop the root target
    router.pop(target0);
    await tester.pumpAndSettle();
    // It should only remove any descendants of the root target, and not the 
    // root target itself.
    expect(routing.tree, orderedEquals([target0]));
    expect(_bodyTargets(body), orderedEquals([target0]));
  }
);

