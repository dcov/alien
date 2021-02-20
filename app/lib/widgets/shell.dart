import 'package:flutter/material.dart';

import '../widgets/rotatable_back_arrow.dart';
import '../widgets/toolbar.dart';
import '../widgets/widget_extensions.dart';

class ShellEntryComponents {

  const ShellEntryComponents({
    this.titleDecoration,
    this.titleMiddle,
    this.titleTrailing,
    this.contentHandle,
    required this.contentBody,
    this.optionsHandle,
    this.optionsBody
  });

  final DecoratedBox? titleDecoration;

  final Widget? titleMiddle;

  final Widget? titleTrailing;

  final Widget? contentHandle;

  final Widget contentBody;

  final Widget? optionsHandle;

  final Widget? optionsBody;
}

abstract class ShellEntry {

  // This is placed inside of a class instead of being a standalone function to
  // allow entries to have internal state.
  ShellEntryComponents build(BuildContext context);
}

class Shell extends StatefulWidget {

  Shell({
    Key? key,
    required this.rootLayer,
    required this.entries,
    required this.onPopEntry
  }) : super(key: key);

  final Widget rootLayer;

  final List<ShellEntry> entries;

  final VoidCallback onPopEntry;

  @override
  ShellState createState() => ShellState();
}

enum _ShellTransition {
  idle,
  popToEmpty,
  pop,
  pushFromEmpty,
  push,
  replace
}

class ShellState extends State<Shell> with SingleTickerProviderStateMixin {

  late final _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
      vsync: this);

  late var _currentEntries = List.of(widget.entries);

  var _transition = _ShellTransition.idle;

  // When popping or replacing we need to transition from the previously visible entry to the new
  // visible entry, but we can no longer reference the previously visible entry directly from
  // _currrentEntries, which is why we temporarily store it here.
  ShellEntry? _previousEntry;

  // This is only safe to call when it's known that there are entries.
  ShellEntry get _currentEntry => _currentEntries.last;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Shell oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldEntries = _currentEntries;
    final newEntries = List.of(widget.entries);
    if (oldEntries.isEmpty && newEntries.isEmpty) {
      // If they're both empty we can't transition to or from anything.
      return;
    }

    setState(() {
      // Reset the current entries
      _currentEntries = newEntries;

      if (oldEntries.isEmpty) {
        _transition = _ShellTransition.pushFromEmpty;
        assert(_previousEntry == null);
        _controller.forward(from: 0.0).then((_) {
          _transition = _ShellTransition.idle;
        });
        return;
      }

      // If newEntries is empty then we've removed all entries so we'll animate 
      // the title, content, and options layers out of screen.
      if (newEntries.isEmpty) {
        _transition = _ShellTransition.popToEmpty;
        _previousEntry = oldEntries.last;
        _controller.reverse(from: 1.0).then((_) {
          _transition = _ShellTransition.idle;
          _previousEntry = null;
        });
        return;
      }

      if (oldEntries.last == newEntries.last) {
        return;
      }

      final lengthDiff = newEntries.length - oldEntries.length;
      if (lengthDiff == 1 && (oldEntries.last == newEntries[oldEntries.length - 1])) {
        _transition = _ShellTransition.push;
        _previousEntry = oldEntries.last;
        _controller.forward(from: 0.0).then((_) {
          _transition = _ShellTransition.idle;
          _previousEntry = null;
        });
        return;
      }

      if (lengthDiff == -1 && (oldEntries[oldEntries.length - 2] == newEntries.last)) {
        _transition = _ShellTransition.pop;
        _previousEntry = oldEntries.last;
        _controller.reverse(from: 1.0).then((_) {
          _transition = _ShellTransition.idle;
          _previousEntry = null;
        });
        return;
      }
      
      _transition = _ShellTransition.replace;
      _previousEntry = oldEntries.last;
      _controller.forward(from: 0.0).then((_) {
        _transition = _ShellTransition.idle;
        _previousEntry = null;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[
      IgnorePointer(
        ignoring: _controller.isAnimating,
        child: widget.rootLayer)
    ];

    if (_currentEntries.isNotEmpty || _transition != _ShellTransition.idle) {
      final previousComponents = _previousEntry?.build(context);
      final currentComponents = _currentEntry.build(context);
      layers..add(_TitleLayer(
                previousComponents: previousComponents,
                currentComponents: currentComponents,
                transition: _transition,
                totalEntries: _currentEntries.length))
            ..add(_ContentLayer())
            ..add(_OptionsLayer());
    }

    return Stack(children: layers);
  }
}

class _TitleLayer extends StatelessWidget {

  _TitleLayer({
    Key? key,
    this.previousComponents,
    required this.currentComponents,
    required this.transition,
    required this.totalEntries
  }) : super(key: key);

  final ShellEntryComponents? previousComponents;

  final ShellEntryComponents currentComponents;

  final _ShellTransition transition;

  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    return 
  }
}

class _ContentLayer extends StatelessWidget {

  _ContentLayer({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  }
}

class _OptionsLayer extends StatelessWidget {

  _OptionsLayer({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  }
}
