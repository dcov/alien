import 'package:flutter/material.dart';

part 'formatting.dart';
part 'insets.dart';

class CustomTile extends StatelessWidget {

  CustomTile({
    Key key,
    this.padding = const EdgeInsets.all(16.0),
    this.icon,
    @required this.title,
    this.onTap
  }) : super(key: key);

  final EdgeInsets padding;

  final Widget icon;
  
  final Widget title;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: Padding(
        padding: this.padding,
        child: Row(
          children: <Widget>[
            if (icon != null)
              icon,
            Padding(
              padding: icon != null ? const EdgeInsets.only(left: 16.0) : EdgeInsets.zero,
              child: title
            )
          ],
        )
      ),
    );
  }
}