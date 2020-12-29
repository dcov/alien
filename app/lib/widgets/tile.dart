import 'package:flutter/widgets.dart';

import 'pressable.dart';

class CustomTile extends StatelessWidget {

  CustomTile({
    Key key,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.depth,
    this.icon,
    @required this.title,
    this.onTap
  }) : super(key: key);

  final EdgeInsets padding;

  final int depth;

  final Widget icon;
  
  final Widget title;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPress: this.onTap,
      child: Padding(
        padding: this.padding +
          (depth != null ? EdgeInsets.only(left: depth * padding.left) : EdgeInsets.zero),
        child: Row(
          children: <Widget>[
            if (icon != null)
              icon,
            Expanded(
              child: Padding(
                padding: icon != null ? const EdgeInsets.only(left: 12.0) : EdgeInsets.zero,
                child: title))
          ])));
  }
}

