import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';

import '../model/app.dart';
import '../model/post.dart';
import '../model/subreddit.dart';
import '../ui/depth_painter.dart';
import '../ui/icons.dart';
import '../ui/path_router.dart';
import '../ui/post_route.dart';
import '../ui/pressable.dart';
import '../ui/routing.dart';
import '../ui/sublist_header.dart';
import '../ui/subreddit_route.dart';
import '../ui/theming.dart';
import '../ui/toolbar.dart';

class _RouteTreeTile extends StatelessWidget {

  _RouteTreeTile({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          color: Theming.of(context).altCanvasColor),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theming.of(context).altBorderColor,
              width: 1.0),
            borderRadius: BorderRadius.circular(4.0)),
          child: CustomPaint(
            painter: DepthPainter(
              padding: 16.0,
              linePaint: Paint()..color = theming.altBorderColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children)))));
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
    return Padding(
      padding: depth != null ? EdgeInsets.only(left: 16.0 * depth! + 1.0) : EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: depth != null ? theming.altCanvasColor : theming.canvasColor),
        child: Pressable(
          onPress: () => onGoTo(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
              ])))));
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

Widget _buildRoute(RouteEntry route, int depth) {
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

List<Widget> _buildNode(PathNode<RouteEntry> node, int depth, [List<Widget>? result]) {
  result ??= <Widget>[];
  result.add(_buildRoute(node.route, depth));
  if (node.children.isNotEmpty) {
    for (final child in node.children.values) {
      _buildNode(child, depth + 1, result);
    }
  }
  return result;
}

Widget _maybeBuildRouteTree(Map<String, PathNode<RouteEntry>> nodes, String rootPath, Widget nonTreeTileBuilder()) {
  if (nodes.containsKey(rootPath)) {
    return _RouteTreeTile(children: _buildNode(nodes[rootPath]!, 0));
  }
  return nonTreeTileBuilder();
}

class AppRoute extends RootEntry {

  AppRoute({
    required this.app
  });

  final App app;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    final nodes = RoutingExtension(context).nodes;
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
                  nodes,
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
                  nodes,
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
