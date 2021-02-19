import 'logic/init.dart';
import 'views/init_view.dart';

import 'effects.dart';
import 'reddit_credentials.dart';

void main() {
  const runInScriptMode = bool.hasEnvironment('script_mode');
  runLoopWithEffects(
    appId: Credentials.appId,
    appRedirect: Credentials.appRedirect,
    scriptId: runInScriptMode ? Credentials.scriptId : null,
    // If script id is null then the rest of the values are ignored so we can always set them
    scriptSecret: Credentials.scriptSecret,
    scriptUsername: Credentials.scriptUsername,
    scriptPassword: Credentials.scriptPassword,
    initial: InitApp(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      isInScriptMode: runInScriptMode),
    view: InitView());
}
