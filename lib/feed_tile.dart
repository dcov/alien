import 'package:flutter/material.dart';

import 'core/feed.dart';
import 'widgets/tile.dart';

import 'feed_route.dart';

class FeedKindTile extends StatelessWidget {

  FeedKindTile({
    Key? key,
    required this.kind,
    required this.pathPrefix,
  }) : super(key: key);

  final FeedKind kind;

  final String pathPrefix;

  IconData get _feedTypeIcon {
    switch (kind) {
      case FeedKind.home:
        return Icons.home;
      case FeedKind.popular:
        return Icons.trending_up;
      case FeedKind.all:
        return Icons.all_inclusive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () {
        FeedRoute.goTo(
          context,
          kind,
          pathPrefix);
      },
      icon: Icon(_feedTypeIcon),
      title: Text(
        kind.displayName,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}
