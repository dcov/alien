import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/completion.dart';
import 'core/subreddit.dart';
import 'core/thing_store.dart';
import 'widgets/color_swatch.dart';
import 'widgets/icons.dart';
import 'widgets/page_stack.dart';

class AppPage extends PageStackEntry {

  AppPage({
    required ValueKey<String> key,
    String? name,
    required this.app,
  }) : super(key: key, name: name);

  final App app;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState(BuildContext context) {
    _focusNode = FocusNode();
    _textController = TextEditingController(text: '');
  }

  List<Subreddit> _collectSubreddits() {
    final allIds = <String>{
      ...app.defaults.ids,
      ...app.subscriptions.subscribers.keys,
    };
    final subreddits = allIds.map((id) => app.store.idToSubreddit(id)).toList();
    subreddits.sort((s1, s2) => s1.name.toLowerCase().compareTo(s2.name.toLowerCase()));
    return subreddits;
  }

  @override
  Widget build(_) => Connector(builder: (BuildContext context) {
    final swatch = AlienColorSwatch.of(context);
    final stack = context.pageStack;
    final subreddits = _collectSubreddits();
    return Column(children: <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(color: swatch.mainSurface),
        child: Padding(
          padding: EdgeInsets.only(top: appWindow.titleBarHeight),
          child: SizedBox(
            height: 56.0,
            child: NavigationToolbar(
              centerMiddle: false,
              middle: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: swatch.altSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: SizedBox.expand(child: EditableText(
                    controller: _textController,
                    focusNode: _focusNode,
                    style: TextStyle(),
                    cursorColor: Colors.orange,
                    backgroundCursorColor: Colors.orange,
                    onChanged: (String value) {
                      context.then(UpdateCompletionQuery(newQuery: value));
                    },
                  )),
                ),
              ),
              trailing: SizedBox.square(
                dimension: 56.0,
                child: Center(child: Icon(Icons.settings)),
              ),
            ),
          ),
        ),
      ),
      Expanded(child: CustomScrollView(slivers: <Widget>[
        if (app.accounts.users.isNotEmpty)
          SliverList(delegate: SliverChildListDelegate(<Widget>[
            // TODO: Add tiles for account, mail, etc.. here
          ])),
        _HeaderTile(text: 'Subreddits'),
        SliverList(delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _SubredditTile(subreddit: subreddits[index]);
          },
          childCount: subreddits.length,
        )),
      ])),
    ]);
  });
}

class _HeaderTile extends StatelessWidget {

  _HeaderTile({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(child: SizedBox(
      height: 24.0,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: theme.textTheme.caption,
          ),
        ),
      ),
    ));
  }
}

class _SubredditTile extends StatelessWidget {

  _SubredditTile({
    Key? key,
    required this.subreddit,
  }) : super(key: key);

  final Subreddit subreddit;

  @override
  Widget build(BuildContext context) {
    return Material(child: ListTile(
      leading: const Icon(CustomIcons.subreddit),
      title: Text(subreddit.name),
    ));
  }
}
