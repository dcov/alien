import 'package:autotrie/autotrie.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import 'core/app.dart';
import 'core/defaults.dart';
import 'core/subscriptions.dart';
import 'widgets/page_stack.dart';

class _AppPageState {

  _AppPageState({
    required this.completion,
    required this.defaults,
    required this.subscriptions
  });

  AutoComplete completion;
  Defaults? defaults;
  Subscriptions? subscriptions;
}

class AppPage extends PageStackEntry {

  AppPage({
    required ValueKey<String> key,
    String? name,
    required this.app,
  }) : super(key: key, name: name);

  final App app;
  late final _AppPageState _state;

  @override
  void initState(BuildContext context) {
    _state = _AppPageState(
      completion: AutoComplete(engine: SortEngine.entriesOnly()),
      defaults: Defaults(),
      subscriptions: Subscriptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(border: Border(
          bottom: BorderSide(
            width: 0.1,
            color: Colors.grey,
          ),
        )),
        child: SizedBox(
          height: 56.0,
          child: NavigationToolbar(),
        ),
      ),
    ]);
  }
}
