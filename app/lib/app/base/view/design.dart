import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'styled_text.dart';
import 'types.dart';
import 'values.dart';

class MediaPadding extends StatelessWidget {

  MediaPadding({
    Key key,
    @required this.child
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).padding,
      child: child,
    );
  }
}

class IconCaption extends StatelessWidget {

  IconCaption({
    Key key,
    this.icon,
    this.text,
    this.color,
    this.iconSize,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  final IconData icon;
  final String text;
  final Color color;
  final double iconSize;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: <Widget>[
        Icon(icon, color: color, size: iconSize),
        SizedBox(width: 4.0),
        CaptionText(text, color: color)
      ]
    );
  }
}

class CircleDivider extends StatelessWidget {

  static List<Widget> insert(List<Widget> list) {
    final int finalLength = (list.length * 2) - 1;
    for (int i = 1; i < finalLength; i += 2) {
      list.insert(i, const CircleDivider());
    }
    return list;
  }

  const CircleDivider({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      width: 10.0,
      decoration: ShapeDecoration(
        color: Colors.grey,
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.grey
          )
        )
      ),
    );
  }
}

class HorizontalDivider extends StatelessWidget {

  static List<Widget> insert(List<Widget> list, double height, [ Color color ]) {
    final int finalLength = (list.length * 2) - 1;
    for (int i = 1; i < finalLength; i += 2) {
      list.insert(i, HorizontalDivider(height: height, color: color));
    }
    return list;
  }

  const HorizontalDivider({
    Key key,
    @required this.height,
    this.color
  }) : super(key: key);

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 0.0,
        height: height,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color ?? Theme.of(context).dividerColor,
              width: 0.0
            ),
          )
        )
      ),
    );
  }
}

class Heading extends StatelessWidget {

  Heading({
    Key key,
    @required this.primaryColor,
    double dividerHeight = 12.0,
    @required List<Widget> items,
  }) : this.items = dividerHeight != null ? HorizontalDivider.insert(items, dividerHeight) : items,
       super(key: key);

  final Color primaryColor;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IconTheme(
        data: IconThemeData(
          color: primaryColor,
          size: 16.0
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            textBaseline: TextBaseline.alphabetic,
            children: items
          )
        )
      )
    );
  }
}

class HeadingItem extends StatelessWidget {

  const HeadingItem({
    Key key,
    this.onTap,
    this.tooltip,
    @required this.icon,
    @required this.text
  }) : super(key: key);

  final ContextCallback onTap;
  final String tooltip;
  final IconData icon;
  final String text;

  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    Widget result = Padding(
      padding: Insets.threeQuartersHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: iconTheme.size,
            color: iconTheme.color,
          ),
          Padding(
            padding: Insets.quarterLeft,
            child: OverlineText(
              text.toUpperCase(),
              softWrap: false,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
          )
        ],
      )
    );

    if (onTap != null) {
      result = InkWell(
        onTap: () => onTap(context),
        child: result,
      );
    }

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip,
        child: result,
      );
    }

    return result;
  }
}

class ListItem extends StatelessWidget {

  ListItem({
    Key key,
    this.onTap,
    this.icon,
    @required this.title
  }) : super(key: key);

  final VoidCallback onTap;

  final Widget icon;

  final Widget title;

  @override
  Widget build(BuildContext context) {

    final List<Widget> children = List<Widget>();
    if (icon != null)
      children.add(
        Padding(
          padding: Insets.fullRight,
          child: icon,
        )
      );
    
    children.add(title);

    Widget child = Padding(
      padding: Insets.fullHorizontalHalfVertical,
      child: Row(children: children),
    );

    if (onTap != null) {
      child = Material(
        type: MaterialType.canvas,
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      );
    }

    return child;
  }
}

class CircleIcon extends StatelessWidget {

  CircleIcon(
    this.icon, {
    Key key,
    this.circleRadius = 12.0,
    this.circleColor,
    this.iconSize = 16.0,
    this.iconColor,
  });

  final IconData icon;

  final double circleRadius;

  final Color circleColor;

  final double iconSize;

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: circleRadius,
      backgroundColor: circleColor,
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}

class OptionsBar extends StatelessWidget {

  OptionsBar({
    Key key,
    this.backgroundColor,
    this.dividerHeight = 16.0,
    this.dividerColor,
    this.options = const <Widget>[]
  }) : assert(options != null),
       super(key: key);

  final Color backgroundColor;
  final double dividerHeight;
  final Color dividerColor;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = this.backgroundColor ?? theme.canvasColor;
    return Material(
      type: MaterialType.canvas,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: HorizontalDivider.insert(options, dividerHeight, theme.dividerColor)
      ),
    );
  }
}

class OptionsBarItem extends StatelessWidget {

  OptionsBarItem({
    Key key,
    this.onTap,
    this.color,
    this.icon,
    this.text
  }) : super(key: key);

  final ContextCallback onTap;
  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = (this.color ?? theme.textTheme.overline.color);
    return Expanded(
      child: InkWell(
        onTap: () => onTap(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: color,
              size: 12.0,
            ),
            Padding(
              padding: Insets.quarterLeft,
              child: OverlineText(
                text.toUpperCase(),
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}