import 'package:muex/muex.dart';

part 'completion.g.dart';

class Entry {

  String get key => _key;
  late String _key;

  Object get value => _value;
  late Object _value;

  final List<int> indices = <int>[];
}

abstract class Completion implements Model {

  factory Completion() {
    return _$Completion(query: '');
  }

  Map<String, Entry> get candidates;

  List<List<Entry>> get matches;

  String get query;
  set query(String value);

  List<Entry> get results;
  set results(List<Entry> value);
}

abstract class CompletionOwner {

  Completion get completion;
}

class AddCompletionCandidates implements Update {

  AddCompletionCandidates({ required this.candidates });

  final Map<String, Object> candidates;

  @override
  Action update(CompletionOwner owner) {
    final completion = owner.completion;

    for (final candidate in candidates.entries) {
      final entry = completion.candidates.putIfAbsent(
        candidate.key,
        () => Entry(),
      );

      entry.._key = candidate.key
           .._value = candidate.value;
    }

    return None();
  }
}

class RemoveCompletionCandidates implements Update {

  RemoveCompletionCandidates({ required this.candidates });

  final List<String> candidates;

  @override
  Action update(CompletionOwner owner) {
    final completion = owner.completion;

    for (final key in candidates) {
      completion.candidates.remove(key);
    }

    return None();
  }
}

class UpdateCompletionQuery implements Update {

  UpdateCompletionQuery({
    required this.newQuery,
  });

  final String newQuery;

  @override
  Action update(CompletionOwner owner) {
    final completion = owner.completion;

    final oldQuery = completion.query;
    completion.query = newQuery;

    if (newQuery.isEmpty) {
      completion..matches.clear()
                ..results = const <Entry>[];
      return None();
    }

    int startCharIndex = -1;
    if (oldQuery.isEmpty) {
      assert(completion.matches.isEmpty);
      assert(completion.results.isEmpty);
      startCharIndex = 0;
    } else {
      for (var i = 0; ; i++) {
        final oldQueryEndReached = i >= oldQuery.length;
        final newQueryEndReached = i >= newQuery.length;

        if (oldQueryEndReached) {
          if (newQueryEndReached) {
            // The query did not change in length nor content
            return None();
          }

          // The query was added to
          startCharIndex = i;
          break;
        }

        if (newQueryEndReached) {
          // The query was deleted from
          break;
        }

        if (oldQuery[i] != newQuery[i]) {
          // The query changed starting at index i
          startCharIndex = i;
          break;
        }

        // No differences found yet so continue
        continue;
      }
    }

    if (startCharIndex >= 0) {
      for (var i = startCharIndex; i < newQuery.length; i++) {
        final char = newQuery[i];
        final Iterable<Entry> potentialMatches = (i == 0)
              ? completion.candidates.values
              : completion.matches[i - 1];
        final matches = <Entry>[];

        for (final entry in potentialMatches) {
          final startIndex = i == 0 ? 0 : (entry.indices[i - 1] + 1);

          for (var ii = startIndex; ii < entry.key.length; ii++) {
            if (entry.key[ii] == char) {
              matches.add(entry);
              if (entry.indices.length == i) {
                entry.indices.add(ii);
              } else {
                entry.indices[i] = ii;
              }
              break;
            }
          }
        }

        if (completion.matches.length == i) {
          completion.matches.add(matches);
        } else {
          completion.matches[i] = matches;
        }
      }
    }

    completion.results = completion.matches[newQuery.length - 1];

    return None();
  }
}
