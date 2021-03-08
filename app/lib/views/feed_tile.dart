import 'package:flutter/material.dart';

import '../models/feed.dart';

class FeedTile extends StatelessWidget {

  FeedTile({
    Key? key,
    required this.feed,
  }) : super(key: key);

  final Feed feed;

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
      onTap: () => _showFeedPage(
        context: context,
        feed: feed),
      icon: Icon(_feedTypeIcon),
      title: Text(
        feed.displayName,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500)));
  }
}
