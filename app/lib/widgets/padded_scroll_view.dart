import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'shell.dart';

class PaddedScrollView extends StatelessWidget {

  PaddedScrollView({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.slivers = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final List<Widget> slivers;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = context.bodyAreaPadding;
    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      center: center,
      anchor: anchor,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      slivers: <Widget>[
        if (padding.top != 0)
          SliverToBoxAdapter(child: SizedBox(
            height: padding.top,
          )),
        ...slivers,
        if (padding.bottom != 0)
          SliverToBoxAdapter(child: SizedBox(
            height: padding.top,
          )),
      ]
    );
  }
}
