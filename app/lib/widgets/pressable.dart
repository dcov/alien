import 'package:flutter/widgets.dart';

const Duration _kPressDuration = Duration(milliseconds: 100);

class Pressable extends StatefulWidget {

  Pressable({
    Key? key,
    this.controller,
    this.alignment = Alignment.center,
    this.behavior = HitTestBehavior.translucent,
    this.onPress,
    this.onLongPress,
    required this.child,
  }) : super(key: key);

  final AnimationController? controller;

  final Alignment alignment;

  final HitTestBehavior behavior;

  final VoidCallback? onPress;

  final VoidCallback? onLongPress;

  final Widget child;

  static AnimationController createController({ required TickerProvider vsync }) {
    return AnimationController(
      duration: _kPressDuration,
      vsync: vsync,
      value: 1.0,
    );
  }

  @override
  _PressableState createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? Pressable.createController(vsync: this);
  }

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the new [widget] has an [AnimationController]
    if (widget.controller != null) {

      // It does so let's check if it's different than our current [_controller]
      if (_controller != widget.controller) {

        // It's different so we'll check if our current [_controller] was passed to us.
        if (oldWidget.controller != _controller) {

          // The current [_controller] was created by us so let's dispose it.
          _controller.dispose();
        }
        _controller = widget.controller!;
      }
    } else if (oldWidget.controller != null) {
      // We should've been using the controller given to us
      assert(_controller == oldWidget.controller);

      // We weren't passed a new [AnimationController] and our old [_controller]
      // was not owned by us so we'll create one now.
      _controller = Pressable.createController(vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // Our current [_controller] is owned by us so we can safely dispose it.
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(_) {
    _controller.reverse();
  }

  void _handleTapUp(_) {
    _controller.forward();
    if (widget.onPress != null) {
      widget.onPress!();
    }
  }

  void _handleTapCancel() {
    _controller.forward();
  }

  void _handleLongPress() {
    _controller.reverse();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    }
  }

  void _handleLongPressUp() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapCancel: _handleTapCancel,
      onTapUp: _handleTapUp,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      onLongPressUp: widget.onLongPress != null ? _handleLongPressUp : null,
      child: ScaleTransition(
        scale: _controller.drive(Tween(begin: 0.98, end: 1.0)),
        alignment: widget.alignment,
        child: FadeTransition(
          opacity: _controller.drive(Tween(begin: 0.5, end: 1.0)),
          child: widget.child)));
  }
}

class PressableIcon extends StatelessWidget {

  PressableIcon({
    Key? key,
    this.controller,
    this.behavior = HitTestBehavior.translucent,
    this.onPress,
    this.onLongPress,
    required this.icon,
    required this.iconColor,
    this.padding = EdgeInsets.zero,
  }) : assert(onPress != null),
       super(key: key);

  final AnimationController? controller;

  final HitTestBehavior behavior;
  
  final VoidCallback? onPress;

  final VoidCallback? onLongPress;

  final IconData icon;

  final Color iconColor;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      controller: controller,
      behavior: behavior,
      onPress: onPress,
      onLongPress: onLongPress,
      child: Padding(
        padding: padding,
        child: Icon(
          icon,
          color: iconColor)));
  }
}
