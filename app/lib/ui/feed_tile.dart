import 'package:flutter/material.dart';

import '../logic/feeds.dart';
import '../model/feed.dart';
import '../ui/feed_route.dart';
import '../ui/tile.dart';

class FeedTile extends StatelessWidget {

  FeedTile({
    Key? key,
    required this.feed,
    required this.pathPrefix,
  }) : super(key: key);

  final Feed feed;

  final String pathPrefix;

  IconData get _feedTypeIcon {
    switch (feed) {
      case Feed.home:
        return Icons.home;
      case Feed.popular:
        return Icons.trending_up;
      case Feed.all:
        return Icons.all_inclusive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () {
        FeedRoute.goTo(
          context,
          feed,
          pathPrefix);
      },
      icon: Icon(_feedTypeIcon),
      title: Text(
        feed.displayName,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}
