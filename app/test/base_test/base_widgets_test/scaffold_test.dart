part of '../base_test.dart';

class MockEntry extends Mock implements ScaffoldEntry { }

MockEntry _createEntry(int index) {
  final MockEntry entry = MockEntry();
  when(entry.title).thenReturn('Mock $index');
  when(entry.buildTopActions(any)).thenReturn(<Widget>[]);
  when(entry.buildBody(any)).thenReturn(const SizedBox());
  when(entry.buildBottomActions(any)).thenReturn(<Widget>[]);
  return entry;
}

void testScaffold() => testWidgets(
  'Scaffold Test',
  (WidgetTester tester) async {
    final GlobalKey<CustomScaffoldState> scaffoldKey = GlobalKey<CustomScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScaffoldConfiguration(
          barElevation: 0.0,
          barHeight: 48.0,
          bottomLeading: const SizedBox(),
          child: CustomScaffold(
            key: scaffoldKey,
            onPop: () {}
          )
        )
      )
    );

    final CustomScaffoldState scaffold = scaffoldKey.currentState;

    final MockEntry entry0 = _createEntry(0);
    // This returns a [Future] that we can listen to for the animation to finish,
    // but since in a testing enviroment we have to manually pump frames, the
    // animation will never start and the test won't proceed. Instead, we'll await
    // the [tester.pumpAndSettle] method.
    scaffold.push(entry0);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0]));

    final MockEntry entry1 = _createEntry(1);
    scaffold.push(entry1);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0, entry1]));

    scaffold.pop();
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0]));

    final MockEntry entry2 = _createEntry(2);
    scaffold.replace([entry2, entry1]);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry2, entry1]));

    scaffold.pop();
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry2]));

    scaffold.replace([entry0, entry2]);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0, entry2]));

    scaffold.push(entry1);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0, entry2, entry1]));

    scaffold.pop();
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0, entry2]));

    scaffold.pop();
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0]));

    scaffold.push(entry1);
    await tester.pumpAndSettle();
    expect(scaffold.entries, orderedEquals([entry0, entry1]));
  }
);

