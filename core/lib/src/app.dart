import 'package:muex/muex.dart';

import 'accounts.dart';
import 'auth.dart';
import 'context.dart';

part 'app.g.dart';

abstract class App implements Model, AccountsOwner, AuthOwner {

  factory App({
    required bool initialized,
    required Accounts accounts,
    required Auth auth,
  }) = _$App;

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
        initialized: false,
        accounts: Accounts(
          isInScriptMode: isInScriptMode),
        auth: Auth(
          appId: appId,
          appRedirect: appRedirect)),
      then: Then(_InitContext()));
  }
}

class _InitContext implements Effect {

  _InitContext();

  @override
  Future<Then> effect(CoreContext context) async {
    await context.init();
    return Then(_InitCoreState());
  }
}

class _InitCoreState implements Update {

  _InitCoreState();

  @override
  Then update(_) {
    return Then(InitAccounts(
        onInitialized: () => Then(_FinishAppInit()),
        onFailed: () => Then(_FinishAppInit())));
  }
}

class _FinishAppInit implements Update {

  _FinishAppInit();

  @override
  Then update(App app){
    assert(!app.initialized);
    app.initialized = true;
    return Then.done();
  }
}
