import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/context.dart';
import 'core/post.dart';
import 'core/subreddit.dart';
import 'widgets/page_stack.dart';
import 'widgets/splash_screen.dart';

import 'app_page.dart';
import 'page_ids.dart' as pageIds;
import 'post_page.dart';
import 'reddit_credentials.dart';
import 'subreddit_page.dart';

void main() {
  const runInScriptMode = bool.hasEnvironment('script_mode');
  runLoop(
    state: App(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      isInScriptMode: runInScriptMode,
    ),
    container: CoreContext(
      appId: Credentials.appId,
      appRedirect: Credentials.appRedirect,
      scriptId: runInScriptMode ? Credentials.scriptId : null,
      scriptSecret: Credentials.scriptSecret,
      scriptUsername: Credentials.scriptUsername,
      scriptPassword: Credentials.scriptPassword,
    ),
    initial: const InitApp(),
    view: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Connector(builder: (BuildContext context) {
        final app = context.state as App;

        if (!app.initialized) {
          // TODO: use the native platform splash screen functionality instead
          return SplashScreen();
        }

        final theme = Theme.of(context);
        final windowButtonColors = WindowButtonColors(iconNormal: theme.iconTheme.color);
        return Stack(children: <Widget>[
          PageStack(
            onCreateRoot: (BuildContext _, String id, Object? __) {
              return AppPage(key: ValueKey(id), app: app);
            },
            onCreatePage: (BuildContext _, String id, Object? arg) {
              return pageIds.pageFromId(
                id,
                onPostPage: () => PostPage(key: ValueKey(id), post: arg as Post),
                onSubredditPage: () => SubredditPage(key: ValueKey(id), subreddit: arg as Subreddit),
              );
            },
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (_) => appWindow.startDragging(),
            onDoubleTap: () => appWindow.maximizeOrRestore(),
            child: SizedBox(
              height: 48.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Expanded(child: SizedBox.expand()),
                  MinimizeWindowButton(colors: windowButtonColors),
                  MaximizeWindowButton(colors: windowButtonColors),
                  CloseWindowButton(colors: WindowButtonColors(
                    mouseOver: const Color(0xFFD32F2F),
                    iconNormal: windowButtonColors.iconNormal,
                  )),
                ],
              ),
            ),
          ),
        ]);
      }),
    ),
  );

  doWhenWindowReady(() {
    appWindow.minSize = Size(800, 800);
    appWindow.show();
  });
}
