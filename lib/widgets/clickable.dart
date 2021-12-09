import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef ClickableChildBuilder = Widget Function(BuildContext context, bool hovering, Widget? child);

class Clickable extends StatefulWidget {

  Clickable({
    Key? key,
    this.opaque = true,
    this.onClick,
    this.builder,
    this.child,
  }) : super(key: key);

  final bool opaque;

  final VoidCallback? onClick;

  final ClickableChildBuilder? builder;

  final Widget? child;

  @override
  _ClickableState createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {

  bool _hovering = false;

  void _handleEnter(PointerEnterEvent _) {
    setState(() {
      _hovering = true;
    });
  }

  void _handleExit(PointerExitEvent _) {
    setState(() {
      _hovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.opaque ? HitTestBehavior.opaque : null,
      onTap: widget.onClick,
      child: MouseRegion(
        onEnter: _handleEnter,
        onExit: _handleExit,
        opaque: widget.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_hovering ? 0.1 : 0.0),
          ),
          position: DecorationPosition.foreground,
          child: widget.builder != null
            ? widget.builder!(context, _hovering, widget.child)
            : widget.child,
        ),
      ),
    );
  }
}
