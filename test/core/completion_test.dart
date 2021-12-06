import 'package:alien/core/completion.dart';
import 'package:test/test.dart';
import 'package:muex/muex.dart';

class TestState implements CompletionOwner {

  @override
  final completion = Completion();
}

extension on Completion {
  Iterable<Object> get resultValues => this.results.map((entry) => entry.value);

  Iterable<List<int>> get resultIndices => this.results.map((entry) => entry.indices);
}

void main() {
  test('completion test', () {
    final loop = Loop(state: TestState());
    final completion = (loop.state as TestState).completion;

    loop.then(AddCompletionCandidates(
      candidates: <String, Object>{
        'abc' : 1,
        'aac': 4,
      }
    ));

    loop.then(UpdateCompletionQuery(newQuery: 'a'));
    expect(completion.resultValues, equals([1, 4]));
    expect(completion.resultIndices, equals([[0], [0]]));

    loop.then(UpdateCompletionQuery(newQuery: 'ab'));
    expect(completion.resultValues, equals([1]));
    expect(completion.resultIndices, equals([[0, 1]]));

    loop.then(UpdateCompletionQuery(newQuery: 'aa'));
    expect(completion.resultValues, equals([4]));
    expect(completion.resultIndices, equals([[0, 1]]));

    loop.then(UpdateCompletionQuery(newQuery: 'ac'));
    expect(completion.resultValues, equals([1, 4]));
    expect(completion.resultIndices, equals([[0, 2], [0, 2]]));
  });
}
