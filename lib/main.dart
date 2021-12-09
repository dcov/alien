import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/context.dart';
import 'core/post.dart';
import 'core/subreddit.dart';
import 'widgets/clickable.dart';
import 'widgets/color_swatch.dart';
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

        return _AppView(app: app);
      }),
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

  final _pageStackKey = GlobalKey<PageStackState>();
  List<PageStackEntry>? _pageStack;

  late var _menuButtonController = _createController();

  AnimationController _createController() {
    return AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void reassemble() {
    _menuButtonController.dispose();
    super.reassemble();
    _menuButtonController = _createController();
  }

  @override
  void dispose() {
    _menuButtonController.dispose();
    super.dispose();
  }

  Widget _buildMenuIcon(Color color) {
    return SizedBox.fromSize(
      size: appWindow.titleBarButtonSize,
      child: Center(child: AnimatedIcon(
        progress: _menuButtonController,
        icon: AnimatedIcons.menu_close,
        color: color,
      )),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowButtonColors = WindowButtonColors(iconNormal: theme.iconTheme.color);

    Widget menuButton;
    if (_pageStack != null && _pageStack!.length > 1) {
      menuButton = Clickable(
        onClick: () {
          switch (_menuButtonController.status) {
            case AnimationStatus.forward:
            case AnimationStatus.completed:
              _menuButtonController.reverse();
              _pageStackKey.currentState!.popRoot();
              break;
            case AnimationStatus.reverse:
            case AnimationStatus.dismissed:
              _menuButtonController.forward();
              _pageStackKey.currentState!.push(PageStack.rootId, null);
              break;
          }
        },
        child: _buildMenuIcon(theme.iconTheme.color!),
      );
    } else {
      menuButton = _buildMenuIcon(theme.disabledColor);
    }

    return AlienColorSwatch(
      data: AlienColorSwatchData.dark(),
      child: Stack(children: <Widget>[
        PageStack(
          key: _pageStackKey,
          onCreateRoot: (BuildContext _) {
            return AppPage(
              key: ValueKey(PageStack.rootId),
              app: widget.app,
            );
          },
          onCreatePage: (BuildContext _, String id, Object? arg) {
            return pageIds.pageFromId(
              id,
              onPostPage: () => PostPage(
                key: ValueKey(id),
                post: arg as Post,
              ),
              onSubredditPage: () => SubredditPage(
                key: ValueKey(id),
                subreddit: arg as Subreddit,
              ),
            );
          },
          onStackChanged: (newPageStack) {
            setState(() {
              _pageStack = newPageStack;
            });
          }
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => appWindow.startDragging(),
          onDoubleTap: () => appWindow.maximizeOrRestore(),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: SizedBox(
              height: appWindow.titleBarHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  menuButton,
                  const Expanded(child: SizedBox.expand()),
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
          ),
        ),
      ]),
    );
  }
}
