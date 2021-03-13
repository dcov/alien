import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app.dart';
import '../utils/path_router.dart';
import '../views/app_screen.dart';
import '../widgets/shell.dart';
import '../widgets/theming.dart';

class AppLayer extends ShellRoot {

  AppLayer({
    required this.app
  });

  final App app;

  @override
  RootComponents build(
      BuildContext context,
      ValueListenable<Map<String, PathNode<ShellRoute>>> nodesListenable,
      ValueListenable<List<ShellRoute>> stackListenable
    ) {
    return RootComponents(
      layer: ValueListenableBuilder(
        valueListenable: nodesListenable,
        builder: (_, Map<String, PathNode<ShellRoute>> nodes, __) {
          return AppScreen(
            app: app,
            nodes: nodes);
        }),
      handle: _AppHandle(
        stack: stackListenable),
      drawer: const SizedBox());
  }
}

class _AppHandle extends StatelessWidget {

  _AppHandle({
    Key? key,
    required this.stack
  }) : super(key: key);

  final ValueListenable<List<ShellRoute>> stack;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return ValueListenableBuilder(
      valueListenable: stack,
      builder: (BuildContext context, List<ShellRoute> stack, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (stack.isNotEmpty)
              GestureDetector(
                onTap: () {
                  context.makeRouteVisible();
                },
                child: Center(
                  child: Transform(
                    transform: Matrix4.rotationZ(math.pi * 0.5),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: theming.iconColor)))),

          ]);
      });
  }
}
