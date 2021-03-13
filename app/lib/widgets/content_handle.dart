import 'package:flutter/material.dart';

import '../widgets/theming.dart';

class ContentHandleItem {

  ContentHandleItem({
    required this.icon,
    required this.text,
    this.onTap,
    this.onLongPress
  });

  final IconData icon;

  final String text;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;
}

class ContentHandle extends StatelessWidget {

  ContentHandle({
    Key? key,
    this.items = const <ContentHandleItem>[],
    this.iconSize = 12.0,
    this.iconColor,
  }) : super(key: key);

  final List<ContentHandleItem> items;

  final double iconSize;

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items.map((ContentHandleItem item) {
          return GestureDetector(
            onTap: item.onTap,
            onLongPress: item.onLongPress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Icon(
                  item.icon,
                  size: 16.0,
                  color: iconColor ?? theming.iconColor),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text(
                    item.text,
                    style: theming.captionText))
              ]));
        }).toList()));
  }
}
