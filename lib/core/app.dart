import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'completion.dart';
import 'context.dart';
import 'defaults.dart';
import 'subscriptions.dart';
import 'thing_store.dart';

part 'app.g.dart';

abstract class App implements Model, AccountsOwner, AuthOwner, CompletionOwner,
    DefaultsOwner, SubscriptionsOwner, ThingStoreOwner {

  factory App({
    required String appId,
    required String appRedirect,
    required bool isInScriptMode,
  }) {
    return _$App(
      initialized: false,
      accounts: Accounts(isInScriptMode: isInScriptMode),
      auth: Auth(
        appId: appId,
        appRedirect: appRedirect,
      ),
      completion: Completion(),
      defaults: Defaults(),
      store: ThingStore(),
      subscriptions: Subscriptions(),
    );
  }

  bool get initialized;
  set initialized(bool value);
}

class InitApp implements Effect {
  
  const InitApp();

  @override
  Future<Action> effect(CoreContext context) async {
    await context.init();
    return Chained({
      const InitAccounts(),
      Unchained({
        const RefreshDefaults(),
        const RefreshSubscriptions(),
      }),
      Update((App app) {
        app.initialized = true;
        return None();
      }),
    });
  }
}
