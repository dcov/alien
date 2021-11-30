import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'completion.dart';
import 'context.dart';
import 'subscriptions.dart';
import 'user.dart';

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

  Map<User, Subscriptions> get subscriptions;
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
      then: Then(const _InitContext()),
    );
  }
}

class _InitContext implements Effect {

  const _InitContext();

  @override
  Future<Then> effect(CoreContext context) async {
    await context.init();
    return Then(const _InitCoreState());
  }
}

class _InitCoreState implements Update {

  const _InitCoreState();

  @override
  Then update(_) {
    return Then(InitAccounts(
      onInitialized: () => Then(const _LoadSubscriptions()),
      onFailed: () => Then(const _FinishAppInit()),
    ));
  }
}

class _LoadSubscriptions implements Update {

  const _LoadSubscriptions();

  @override
  Then update(App app) {
    return Then.done();
  }
}

class _FinishAppInit implements Update {

  const _FinishAppInit();

  @override
  Then update(App app) {
    assert(!app.initialized);
    app.initialized = true;
    return Then.done();
  }
}
