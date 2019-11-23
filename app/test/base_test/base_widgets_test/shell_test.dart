part of '../base_test.dart';

class MockEntry extends Mock implements ShellAreaEntry { }

MockEntry _createEntry(int index) {
  final MockEntry entry = MockEntry();
  when(entry.title).thenReturn('Mock $index');
  when(entry.buildTopActions(any)).thenReturn(<Widget>[]);
  when(entry.buildBody(any)).thenReturn(const SizedBox());
  when(entry.buildBottomActions(any)).thenReturn(<Widget>[]);
  return entry;
}

void testShell() => testWidgets(
  'Shell Area Test',
  (WidgetTester tester) async {
    final GlobalKey<ShellAreaState> shellKey = GlobalKey<ShellAreaState>();
    await tester.pumpWidget(
      MaterialApp(
        home: ShellArea(key: shellKey)
      )
    );

    final ShellAreaState shell = shellKey.currentState;

    final MockEntry entry0 = _createEntry(0);
    // This returns a [Future] that we can listen to for the animation to finish,
    // but since in a testing enviroment we have to manually pump frames, the
    // animation will never start and the test won't proceed. Instead, we'll await
    // the [tester.pumpAndSettle] method.
    shell.push(entry0);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0]));

    final MockEntry entry1 = _createEntry(1);
    shell.push(entry1);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0, entry1]));

    shell.pop();
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0]));

    final MockEntry entry2 = _createEntry(2);
    shell.replace([entry2, entry1]);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry2, entry1]));

    shell.pop();
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry2]));

    shell.replace([entry0, entry2]);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0, entry2]));

    shell.push(entry1);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0, entry2, entry1]));

    shell.pop();
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0, entry2]));

    shell.pop();
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0]));

    shell.push(entry1);
    await tester.pumpAndSettle();
    expect(shell.entries, orderedEquals([entry0, entry1]));
  }
);

