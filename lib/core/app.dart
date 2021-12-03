import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'completion.dart';
import 'context.dart';
import 'subscriptions.dart';

part 'app.g.dart';

abstract class App implements Model, AccountsOwner, AuthOwner, CompletionOwner {

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
    );
  }

  bool get initialized;
  set initialized(bool value);
}

class InitApp implements Initial {
  
  InitApp({
    required this.appId,
    required this.appRedirect,
    required this.isInScriptMode
  });

  final String appId;

  final String appRedirect;

  final bool isInScriptMode;

  @override
  Init init() {
    return Init(
      state: App(
        appId: appId,
        appRedirect: appRedirect,
        isInScriptMode: isInScriptMode,
      ),
      then: Then(Effect((CoreContext context) async {
        await context.init();
        return Then(InitAccounts(
          then: Then(Update((App app) {
            app.initialized = true;
            return Then(const RefreshSubscriptions());
          })),
        ));
      })),
    );
  }
}
