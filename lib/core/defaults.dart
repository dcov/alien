import 'package:muex/muex.dart';

import '../reddit/endpoints.dart';
import '../reddit/types.dart';

import 'context.dart';
import 'thing_store.dart';
import 'user.dart';

part 'defaults.g.dart';

abstract class Defaults implements Model {

  factory Defaults() {
    return _$Defaults(
      refreshing: false,
      ids: const <String>[],
    );
  }

  bool get refreshing;
  set refreshing(bool value);

  List<String> get ids;
}

abstract class DefaultsOwner {
  Defaults get defaults;
}

class RefreshDefaults implements Update {
  
  const RefreshDefaults();

  @override
  Action update(DefaultsOwner owner) {
    final defaults = owner.defaults;

    if (defaults.refreshing)
      return None();

    final removedIds = defaults.ids.toList(growable: false);
    defaults..refreshing = true
            ..ids.clear();

    return Unchained({
      UnstoreSubreddits(subredditIds: removedIds),
      Effect((CoreContext context) async {
        try {
          final result = await context
            .clientFromUser(null)
            .getSubredditsWhere(
              Subreddits.defaults,
              Page(limit: Page.kMaxLimit),
            );

          return Update((_) {
            final subreddits = result.things.toList(growable: false);
            defaults.ids.addAll(subreddits.map((sub) => sub.id));
            return Chained({
              StoreSubreddits(subreddits: subreddits),
              Update((_) {
                defaults.refreshing = false;
                return None();
              }),
            });
          });
        } catch (_) {
          return Update((_) {
            defaults.refreshing = false;
            return None();
          });
        }
      }),
    });
  }
}
