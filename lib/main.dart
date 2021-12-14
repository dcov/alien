import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/completion.dart';
import 'core/context.dart';
import 'core/post.dart';
import 'core/subreddit.dart';
import 'widgets/color_swatch.dart';
import 'widgets/page_stack.dart';
import 'widgets/splash_screen.dart';

import 'app_screen.dart';
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
      home: Material(child: Connector(builder: (BuildContext context) {
        final app = context.state as App;

        if (!app.initialized) {
          // TODO: use the native platform splash screen functionality instead
          return SplashScreen();
        }

        return _AppView(app: app);
      })),
    ),
  );

  doWhenWindowReady(() {
    appWindow.minSize = Size(800, 800);
    appWindow.show();
  });
}

class _AppView extends StatefulWidget {

  _AppView({
    Key? key,
    required this.app,
  }) : super(key: key);

  final App app;

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> with TickerProviderStateMixin {

  late final _pageStackController = _createPageStackController();
  late var _revealController = AppScreen.createRevealController(this);

  @override
  void reassemble() {
    final value = _revealController.value;
    _revealController.dispose();
    super.reassemble();
    _revealController = AppScreen.createRevealController(this, value);
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  PageStackController _createPageStackController() {
    return PageStackController(
      onCreatePage: (Object arg) {
        return _handlePageObj(arg, null)!;
      },
      onPageAdded: (PageStackEntry page) {
        //_handlePageObj(page.arg, true);
      },
      onPageRemoved: (PageStackEntry page) {
        //_handlePageObj(page.arg, false);
      },
    );
  }

  PageStackEntry? _handlePageObj(Object arg, bool? addOrRemove) {
    if (arg is Subreddit) {
      if (addOrRemove == null) {
        return SubredditPage(key: ValueKey(arg.id), subreddit: arg);
      } else if (addOrRemove) {
        // context.then(AddCompletionCandidates(candidates: { arg.name : arg }));
      } else {
        // context.then(RemoveCompletionCandidates(candidates: { arg.name }));
      }
    }

    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlienColorSwatch(
      data: AlienColorSwatchData.dark(),
      child: Stack(children: <Widget>[
        ValueListenableBuilder(
          valueListenable: _revealController,
          builder: (BuildContext context, double value, Widget? child) {
            return IgnorePointer(
              ignoring: value != 0.0,
              child: child,
            );
          },
          child: PageStackView(controller: _pageStackController),
        ),
        AppScreen(
          app: widget.app,
          pageStackController: _pageStackController,
          revealController: _revealController,
        ),
        _WindowButtonRow(),
      ]),
    );
  }
}

class _WindowButtonRow extends StatelessWidget {

  _WindowButtonRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowButtonColors = WindowButtonColors(iconNormal: theme.iconTheme.color);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => appWindow.startDragging(),
      onDoubleTap: () => appWindow.maximizeOrRestore(),
      child: SizedBox(
        height: appWindow.titleBarHeight,
        child: Row(children: <Widget>[
          const Expanded(child: SizedBox.expand()),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black38,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MinimizeWindowButton(colors: windowButtonColors),
                StatefulBuilder(builder: (_, StateSetter setState) {
                  if (appWindow.isMaximized) {
                    return WindowButton(
                      colors: windowButtonColors,
                      animate: false,
                      onPressed: () {
                        setState(() {
                          appWindow.maximizeOrRestore();
                        });
                      },
                      iconBuilder: (WindowButtonContext buttonContext) {
                        return RestoreIcon(color: buttonContext.iconColor);
                      },
                    );
                  }

                  return MaximizeWindowButton(
                    onPressed: () {
                      setState(() {
                        appWindow.maximizeOrRestore();
                      });
                    },
                    colors: windowButtonColors,
                  );
                }),
                CloseWindowButton(colors: WindowButtonColors(
                  mouseOver: const Color(0xFFD32F2F),
                  iconNormal: windowButtonColors.iconNormal,
                )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
