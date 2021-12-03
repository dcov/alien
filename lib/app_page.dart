import 'package:flutter/material.dart';

import 'core/app.dart';
import 'widgets/page_stack.dart';

class AppPage extends PageStackEntry {

  AppPage({
    required ValueKey<String> key,
    String? name,
    required this.app,
  }) : super(key: key, name: name);

  final App app;

  @override
  void initState(BuildContext context) {
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
