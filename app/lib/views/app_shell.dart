import 'package:flutter/material.dart';

import '../models/app.dart';
import '../widgets/shell.dart';

class AppShell extends StatefulWidget {

  AppShell({
    Key? key,
    required this.app
  }) : super(key: key);

  final App app;

  @override
  AppShellState createState() => AppShellState();
}

class AppShellState extends State<AppShell> {

  App get _app => widget.app;
  
  @override
  Widget build(BuildContext context) {
    return Shell(
      rootLayer: ShellRootLayer(
        body: CustomScrollView()),
      entries: const <ShellEntry>[],
      onPopEntry: () { });
  }
}
