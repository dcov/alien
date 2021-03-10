import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../models/app.dart';
import '../models/subreddit.dart';
import '../utils/path_router.dart';
import '../views/subreddit_route.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';
import '../widgets/sublist_header.dart';
import '../widgets/toolbar.dart';

class AppScreen extends StatelessWidget {

  AppScreen({
    Key? key,
    required this.app,
    required this.nodes
  }) : super(key: key);

  final App app;

  final Map<String, PathNode<ShellRoute>> nodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Connector(
      builder: (BuildContext context) {
        final children = <Widget>[];
        final defaults = app.defaults;
        final subscriptions = app.subscriptions;
        if (defaults != null) {
          children.add(SublistHeader(name: 'DEFAULTS'));
          children.addAll(
            defaults.items.map((Subreddit subreddit) {
              return _SubredditTile(
                depth: 0,
                active: false,
                subreddit: subreddit,
                pathPrefix: 'defaults:');
            }));
        } else {
          assert(subscriptions != null);
          children.add(SublistHeader(name: 'SUBSCRIPTIONS'));
          children.addAll(
            subscriptions!.items.map((Subreddit subreddit) {
              return _SubredditTile(
                depth: 0,
                active: false,
                subreddit: subreddit,
                pathPrefix: 'subscriptions:');
            }));
        }
        return Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: theme.dividerColor))),
              child: Toolbar(
                trailing: PressableIcon(
                  onPress: () {},
                  icon: Icons.settings,
                  iconColor: theme.disabledColor,
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

class _RouteTreeTile extends StatelessWidget {

  _RouteTreeTile({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children);
  }
}

typedef _RouteTileGoToCallback = void Function(BuildContext);

abstract class _RouteTile extends StatelessWidget {

  _RouteTile({
    Key? key,
    required this.depth,
    required this.active,
    required this.icon,
    required this.title,
    required this.onGoTo,
  }) : assert(depth >= 0),
       super(key: key);

  final int depth;

  final bool active;

  final Widget icon;

  final String title;

  final _RouteTileGoToCallback onGoTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: Pressable(
        onPress: () => onGoTo(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0) + EdgeInsets.only(left: 16.0 * depth),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              icon,
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.button))
            ]))));
  }
}

class _SubredditTile extends _RouteTile {

  factory _SubredditTile({
    Key? key,
    required int depth,
    required bool active,
    required Subreddit subreddit,
    required String pathPrefix,
  }) {

    Widget icon;
    if (subreddit.iconImageUrl != null) {
      icon = CircleAvatar(
        radius: 12.0,
        foregroundImage: CachedNetworkImageProvider(subreddit.iconImageUrl));
    } else {
      icon = Icon(
        CustomIcons.subreddit,
        color: Colors.blueGrey,
        size: 24.0);
    }

    return _SubredditTile._(
        key: key,
        depth: depth,
        active: active,
        icon: icon,
        title: subreddit.name,
        onGoTo: (BuildContext context) {
          SubredditRoute.goTo(context, subreddit, pathPrefix);
        });
  }

  _SubredditTile._({
    Key? key,
    required int depth,
    required bool active,
    required Widget icon,
    required String title,
    required _RouteTileGoToCallback onGoTo
  }) : super(
    key: key,
    depth: depth,
    active: active,
    icon: icon,
    title: title,
    onGoTo: onGoTo);
}
