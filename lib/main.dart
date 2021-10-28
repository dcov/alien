import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/context.dart';

import 'init_view.dart';
import 'reddit_credentials.dart';

void main() {
  const runInScriptMode = bool.hasEnvironment('script_mode');
  runLoop(
    initial: InitApp(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      isInScriptMode: runInScriptMode),
    container: CoreContext(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      scriptId: runInScriptMode ? Credentials.scriptId : null,
      scriptSecret: Credentials.scriptSecret,
      scriptUsername: Credentials.scriptUsername,
      scriptPassword: Credentials.scriptPassword),
    view: InitView());
}
