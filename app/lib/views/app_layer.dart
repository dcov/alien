import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../models/app.dart';
import '../models/subreddit.dart';
import '../utils/path_router.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';
import '../widgets/toolbar.dart';

import 'subreddit_route.dart';

class AppLayer extends ShellRoot {

  AppLayer({ required this.app });

  final App app;

  @override
  RootComponents build(
      BuildContext context,
      ValueListenable<Map<String, PathNode<ShellRoute>>> nodes,
      ValueListenable<List<ShellRoute>> stack
    ) {
    return RootComponents(
      layer: _AppHome(
        app: app,
        nodes: nodes,
        stack: stack),
      handle: _RoutingHandle(
        nodes: nodes,
        stack: stack),
      drawer: const SizedBox());
  }
}

class _AppHome extends StatelessWidget {

  _AppHome({
    Key? key,
    required this.app,
    required this.nodes,
    required this.stack
  }) : super(key: key);

  final App app;

  final ValueListenable<Map<String, PathNode<ShellRoute>>> nodes;

  final ValueListenable<List<ShellRoute>> stack;

  @override
  Widget build(BuildContext context) {
    return Connector(
      builder: (BuildContext context) {
        final children = <Widget>[];
        final defaults = app.defaults;
        final subscriptions = app.subscriptions;
        if (defaults != null) {
          children.add(_SublistHeader(name: 'DEFAULTS'));
          children.addAll(
            defaults.items.map((Subreddit subreddit) {
              return SubredditTile(
                subreddit: subreddit,
                pathPrefix: 'defaults:');
            }));
        } else {
          assert(subscriptions != null);
          children.add(_SublistHeader(name: 'SUBSCRIPTIONS'));
          children.addAll(
            subscriptions!.items.map((Subreddit subreddit) {
              return SubredditTile(
                subreddit: subreddit,
                pathPrefix: 'subscriptions:');
            }));
        }
        return Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border( bottom: BorderSide(
                    width: 0.0,
                    color: Colors.grey))),
              child: Toolbar(
                leading: PressableIcon(
                  onPress: () {},
                  icon: Icons.settings,
                  iconColor: Colors.grey,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0)))),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: children))
          ]);
      });
  }
}

class _RoutingHandle extends StatelessWidget {

  _RoutingHandle({
    Key? key,
    required this.nodes,
    required this.stack
  }) : super(key: key);

  final ValueListenable<Map<String, PathNode<ShellRoute>>> nodes;

  final ValueListenable<List<ShellRoute>> stack;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stack,
      builder: (_, List<ShellRoute> stack, __) {
        return Stack(
          children: <Widget>[
            IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor),
                child: const SizedBox.expand())),
            SizedBox(
              height: 48.0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.add)
                ]))
          ]);
      });
  }
}

class _SublistHeader extends StatelessWidget {

  _SublistHeader({
    Key? key,
    required this.name
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: SizedBox(
        height: 30.0,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.grey.shade700,
                letterSpacing: 1.0,
                fontSize: 10.0,
                fontWeight: FontWeight.w700))))));
  }
}
