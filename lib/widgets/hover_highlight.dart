import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HoverHighlight extends StatefulWidget {

  HoverHighlight({
    Key? key,
    this.opaque = true,
    required this.child,
  }) : super(key: key);

  final bool opaque;

  final Widget child;

  @override
  _HoverHighlightState createState() => _HoverHighlightState();
}

class _HoverHighlightState extends State<HoverHighlight> {

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
    return MouseRegion(
      onEnter: _handleEnter,
      onExit: _handleExit,
      opaque: widget.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_hovering ? 0.5 : 0.0),
        ),
        position: DecorationPosition.foreground,
        child: widget.child,
      ),
    );
  }
}