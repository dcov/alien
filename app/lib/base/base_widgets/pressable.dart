part of '../base.dart';

const Duration _kPressDuration = Duration(milliseconds: 100);

class Pressable extends StatefulWidget {

  Pressable({
    Key key,
    this.controller,
    this.alignment = Alignment.center,
    @required this.onPress,
    this.onLongPress,
    @required this.child,
  }) : assert(alignment != null),
       assert(onPress != null),
       assert(child != null),
       super(key: key);

  final AnimationController controller;

  final Alignment alignment;

  final VoidCallback onPress;

  final VoidCallback onLongPress;

  final Widget child;

  static AnimationController createController({ @required TickerProvider vsync }) {
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

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _controller = Pressable.createController(vsync: this);
    }
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
        _controller = widget.controller;
      }
    } else if (oldWidget.controller != null) {
      // We weren't passed a new [AnimationController] and our old [_controller]
      // was not owned by us so we'll create one now.
      _controller = Pressable.createController(vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // Our current [_controller] is owner by us so let's dispose it.
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(_) {
    _controller.reverse();
  }

  void _handleTapUp(_) {
    _controller.forward();
    widget.onPress();
  }

  void _handleTapCancel() {
    _controller.forward();
  }

  void _handleLongPress() {
    _controller.reverse();
    widget.onLongPress();
  }

  void _handleLongPressUp() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
          child: widget.child,
        ),
      )
    );
  }
}

