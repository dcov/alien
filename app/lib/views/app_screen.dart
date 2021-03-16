import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../models/app.dart';
import '../models/post.dart';
import '../models/subreddit.dart';
import '../utils/path_router.dart';
import '../views/post_route.dart';
import '../views/subreddit_route.dart';
import '../widgets/icons.dart';
import '../widgets/pressable.dart';
import '../widgets/shell.dart';
import '../widgets/sublist_header.dart';
import '../widgets/theming.dart';
import '../widgets/toolbar.dart';

class AppScreen extends StatelessWidget {

  AppScreen({
    Key? key,
    required this.app,
    required this.nodes
  }) : super(key: key);

  final App app;

  final Map<String, PathNode<ShellRoute>> nodes;

  Widget _maybeBuildRouteTree(String rootPath, Widget nonTreeTileBuilder()) {
    if (nodes.containsKey(rootPath)) {
      return _RouteTreeTile(children: _buildNode(nodes[rootPath]!, 0));
    }
    return nonTreeTileBuilder();
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Connector(
      builder: (BuildContext context) {
        final children = <Widget>[];
        final defaults = app.defaults;
        final subscriptions = app.subscriptions;
        if (defaults != null) {
          children.add(SublistHeader(name: 'DEFAULTS'));
          children.addAll(
            defaults.items.map((Subreddit subreddit) {
              final path = SubredditRoute.pathFrom(subreddit, 'defaults:');
              return _maybeBuildRouteTree(
                  path,
                  () => _SubredditRouteTile(subreddit: subreddit, path: path));
            }));
        } else {
          assert(subscriptions != null);
          children.add(SublistHeader(name: 'SUBSCRIPTIONS'));
          children.addAll(
            subscriptions!.items.map((Subreddit subreddit) {
              final path = SubredditRoute.pathFrom(subreddit, 'subscriptions:');
              return _maybeBuildRouteTree(
                  path,
                  () => _SubredditRouteTile(subreddit: subreddit, path: path));
            }));
        }
        return Column(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theming.canvasColor,
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: theming.borderColor))),
              child: Toolbar(
                leading: PressableIcon(
                  onPress: () {},
                  icon: Icons.settings,
                  iconColor: theming.iconColor,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theming.of(context).altCanvasColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children));
  }
}

typedef _RouteTileGoToCallback = void Function(BuildContext);

class _RouteTile extends StatelessWidget {

  _RouteTile({
    Key? key,
    this.depth,
    required this.icon,
    required this.title,
    required this.onGoTo,
  }) : assert(depth == null || depth >= 0),
       super(key: key);

  final int? depth;

  final Widget icon;

  final String title;

  final _RouteTileGoToCallback onGoTo;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    var padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0);
    if (depth != null) {
      padding += EdgeInsets.only(left: 16.0 * depth!);
    }

    return Pressable(
        onPress: () => onGoTo(context),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              icon,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theming.titleText)))
            ])));
  }
}

class _SubredditRouteTile extends StatelessWidget {

  _SubredditRouteTile({
    Key? key,
    this.depth,
    required this.subreddit,
    required this.path,
  }) : super(key: key);

  final int? depth;

  final Subreddit subreddit;

  final String path;

  @override
  Widget build(BuildContext context) {
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

    return _RouteTile(
      key: key,
      depth: depth,
      icon: icon,
      title: subreddit.name,
      onGoTo: (BuildContext context) {
        SubredditRoute.goTo(context, subreddit, path);
      });
  }
}

class _PostRouteTile extends StatelessWidget {

  _PostRouteTile({
    Key? key,
    this.depth,
    required this.post,
    required this.path,
  }) : super(key: key);

  final int? depth;

  final Post post;

  final String path;

  @override
  Widget build(BuildContext context) {
    return _RouteTile(
      depth: depth,
      icon: Icon(Icons.comment),
      title: post.title,
      onGoTo: (BuildContext context) {
        PostRoute.goTo(context, post, path);
      });
  }
}

List<Widget> _buildNode(PathNode<ShellRoute> node, int depth, [List<Widget>? result]) {
  result ??= <Widget>[];
  result.add(_buildRoute(node.route, depth));
  if (node.children.isNotEmpty) {
    for (final child in node.children.values) {
      _buildNode(child, depth + 1, result);
    }
  }
  return result;
}

Widget _buildRoute(ShellRoute route, int depth) {
  if (route is SubredditRoute) {
    return _SubredditRouteTile(
      depth: depth,
      subreddit: route.subreddit,
      path: route.path);
  } else if (route is PostRoute) {
    return _PostRouteTile(
      depth: depth,
      post: route.post,
      path: route.path);
  } else {
    throw UnimplementedError('_RouteTile for $route has not been implemented');
  }
}
