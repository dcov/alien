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
    await tester.pumpWidget(CustomScaffold(
      key: scaffoldKey,
      onPop: () {}
    ));

    final CustomScaffoldState scaffold = scaffoldKey.currentState;

    final MockEntry entry0 = _createEntry(0);
    await scaffold.push(entry0);
    expect(scaffold.entries, orderedEquals([entry0]));

    final MockEntry entry1 = _createEntry(1);
    await scaffold.push(entry1);
    expect(scaffold.entries, orderedEquals([entry0, entry1]));

    await scaffold.pop();
    expect(scaffold.entries, orderedEquals([entry0]));

    final MockEntry entry2 = _createEntry(2);
    await scaffold.replace([entry2, entry1]);
    expect(scaffold.entries, orderedEquals([entry2, entry1]));

    await scaffold.replace([entry0, entry2]);
    expect(scaffold.entries, orderedEquals([entry0, entry2]));
  }
);

