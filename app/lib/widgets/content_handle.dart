import 'package:flutter/material.dart';

class ContentHandleItem {

  ContentHandleItem({
    required this.icon,
    required this.color,
    required this.text,
    this.onTap,
    this.onLongPress
  });

  final IconData icon;

  final Color color;

  final String text;

  final VoidCallback? onTap;

  final VoidCallback? onLongPress;
}

class ContentHandle extends StatelessWidget {

  ContentHandle({
    Key? key,
    this.items = const <ContentHandleItem>[],
    this.iconSize = 12.0
  }) : super(key: key);

  final List<ContentHandleItem> items;

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items.map((ContentHandleItem item) {
          return GestureDetector(
            onTap: item.onTap,
            onLongPress: item.onLongPress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  item.icon,
                  size: iconSize,
                  color: item.color),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 12.0))
              ]));
        }).toList()));
  }
}
