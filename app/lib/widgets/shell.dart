import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/pressable.dart';
import '../widgets/toolbar.dart';
import '../widgets/widget_extensions.dart';

class ShellEntryComponents {

  ShellEntryComponents({
    this.titleDecoration,
    this.titleMiddle,
    this.titleTrailing,
    this.contentHandle,
    required this.contentBody,
    this.optionsHandle,
    this.optionsBody,
    this.drawer
  });

  final BoxDecoration? titleDecoration;

  final Widget? titleMiddle;

  final Widget? titleTrailing;

  final Widget? contentHandle;

  final Widget contentBody;

  final Widget? optionsHandle;

  final Widget? optionsBody;

  final Widget? drawer;
}

abstract class ShellEntry {

  // This is placed inside of a class instead of being a standalone function to
  // allow entries to have internal state.
  ShellEntryComponents build(BuildContext context);
}

enum _LayersTransition {
  // idle
  idleAtRoot,
  idleAtEntry,
  idleAtOptions,

  // navigation
  pushFromOrPopToEmpty,
  push,
  pop,
  replace,

  // drag
  dragToPop,
  dragToPopToEmpty,
  dragToExpandOrCollapseEntry,
  dragToExpandOrCollapseOptions,

  // expand/collapse
  expandOrCollapseEntry,
  expandOrCollapseOptions,
}

enum _DrawersState {
  // root drawer
  dragToOrFromRoot,
  revealOrHideRoot,


  // entry drawer
  dragToOrFromEntry,
  revealOrHideEntry,
}

class _TitleLayerPosition extends SingleChildLayoutDelegate {

  _TitleLayerPosition({ required this.position }) : super(relayout: position);

  final Animation<double> position;

  @override
  Offset getPositionForChild(_, Size childSize) {
    return Offset(
      0.0,
      -childSize.height * (1.0 - position.value));
  }

  @override
  bool shouldRelayout(_TitleLayerPosition oldDelegate) {
    return this.position != oldDelegate.position;
  }
}

class _TitleLayer extends StatelessWidget {

  _TitleLayer({
    Key? key,
    this.hiddenComponents,
    required this.visibleComponents,
    required this.animation,
    required this.layersTransition,
    this.replacedEntriesLength,
    required this.entriesLength,
    this.onPopEntry
  }) : super(key: key) {
    assert((replacedEntriesLength == null && layersTransition != _LayersTransition.replace) ||
           (replacedEntriesLength != null && layersTransition == _LayersTransition.replace));
    assert(!_renderHiddenComponents || hiddenComponents != null);
    _decorationTween = DecorationTween(
      begin: hiddenComponents?.titleDecoration ?? const BoxDecoration(),
      end: visibleComponents.titleDecoration ?? const BoxDecoration());
  }

  final ShellEntryComponents? hiddenComponents;

  final ShellEntryComponents visibleComponents;

  final Animation<double> animation;

  final _LayersTransition layersTransition;

  final int? replacedEntriesLength;

  final int entriesLength;

  final VoidCallback? onPopEntry;

  late final DecorationTween _decorationTween;

  // _TitleLayerPosition animates our position based on the value of an animation, so in
  // effect, this getter determines our position based on the value of layersTransition.
  Animation<double> get _position {
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
        // We are out of frame.
        return kAlwaysDismissedAnimation;
      case _LayersTransition.idleAtEntry:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseOptions:
        // We are in frame
        return kAlwaysCompleteAnimation;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
      case _LayersTransition.dragToExpandOrCollapseEntry:
      case _LayersTransition.expandOrCollapseEntry:
        // We are animating in or out of frame
        return animation;
    }
  }

  // The back arrow rotates from a downward facing position, to a leftward facing position
  // as the animation goes from 0.0 to 1.0.
  static const _kBackArrowStartingAngle = 90 * (math.pi/180);

  // Because the transitions run in such a way that a push animates from 0.0 to 1.0, and a
  // pop animates from 1.0 to 0.0, we take the inverse of that so that a push animates the
  // the back arrow back to its natural leftward facing position, and a pop animates it back to
  // its starting downward facing position;
  double _getBackArrowAngle(double value) {
    // inverse the animation value
    value = 1.0 - value;
    switch (layersTransition) {
      case _LayersTransition.idleAtRoot:
      case _LayersTransition.idleAtEntry:
      case _LayersTransition.idleAtOptions:
      case _LayersTransition.dragToExpandOrCollapseEntry:
      case _LayersTransition.dragToExpandOrCollapseOptions:
      case _LayersTransition.expandOrCollapseEntry:
      case _LayersTransition.expandOrCollapseOptions:
        value = (entriesLength < 2 ? 1.0 : 0.0);
        break;
      case _LayersTransition.pushFromOrPopToEmpty:
      case _LayersTransition.dragToPopToEmpty:
        value = 1.0;
        break;
      case _LayersTransition.push:
        value = (entriesLength == 2 ? value : 0.0);
        break;
      case _LayersTransition.pop:
        value = (entriesLength == 1 ? value : 0.0);
        break;
      case _LayersTransition.dragToPop:
        value = (entriesLength == 2 ? value : 0.0);
        break;
      case _LayersTransition.replace:
        if (replacedEntriesLength! < 2) {
          value = (entriesLength < 2 ? 1.0 : value);
        } else {
          value = (entriesLength > 2 ? 0.0 : (1.0 - value));
        }
        break;
    }
    return _kBackArrowStartingAngle * value;
  }

  bool get _renderHiddenComponents {
    switch (layersTransition) {
      case _LayersTransition.push:
      case _LayersTransition.pop:
      case _LayersTransition.replace:
      case _LayersTransition.dragToPop:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _TitleLayerPosition(
        position: _position),
      child: ValueListenableBuilder(
        valueListenable: animation,
        builder: (BuildContext context, double value, _) {
          final leading = Pressable(
            onPress: onPopEntry,
            child: Transform.rotate(
              angle: _getBackArrowAngle(value),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black)));

          final middle = Stack(
            children: <Widget>[
              if (_renderHiddenComponents)
                Opacity(
                  opacity: 1.0 - value,
                  child: hiddenComponents!.titleMiddle),
              Opacity(
                opacity: value,
                child: visibleComponents.titleMiddle),
            ]);

          final trailing = Stack(
            children: <Widget>[
              if (_renderHiddenComponents)
                Opacity(
                  opacity: 1.0 - value,
                  child: hiddenComponents!.titleMiddle),
              Opacity(
                opacity: value,
                child: visibleComponents.titleMiddle)
            ]);

          return DecoratedBox(
            decoration: _decorationTween.transform(value),
            child: Padding(
              padding: EdgeInsets.only(bottom: context.mediaPadding.bottom),
              child: Toolbar(
                leading: leading,
                middle: middle,
                trailing: trailing)));
        }));
  }
}

class _ContentLayer extends StatelessWidget {

  _ContentLayer({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class _OptionsLayer extends StatelessWidget {

  _OptionsLayer({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class Shell extends StatefulWidget {

  Shell({
    Key? key,
    required this.rootLayer,
    this.rootDrawer,
    this.entries = const <ShellEntry>[],
    required this.onPopEntry
  }) : super(key: key);

  final Widget rootLayer;
  
  final Widget? rootDrawer;

  final List<ShellEntry> entries;

  final VoidCallback onPopEntry;

  @override
  ShellState createState() => ShellState();
}

class ShellState extends State<Shell> with SingleTickerProviderStateMixin { 
  late final _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
      vsync: this);

  late var _entries = List.of(widget.entries);

  var _layersTransition = _LayersTransition.idleAtRoot;

  int? _replacedEntriesLength;
  ShellEntry? _hiddenEntry;
  ShellEntry? _visibleEntry;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Shell oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldEntries = _entries;
    final newEntries = List.of(widget.entries);
    if (oldEntries.isEmpty && newEntries.isEmpty) {
      // If they're both empty we can't transition to or from anything.
      return;
    }

    setState(() {
      _entries = newEntries;

      if (oldEntries.isEmpty) {
        _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
        _hiddenEntry = null;
        _visibleEntry = _entries.last;
        _controller.forward(from: 0.0).then((_) {
          setState(() {
            _layersTransition = _LayersTransition.idleAtEntry;
            _visibleEntry = null;
          });
        });
        return;
      }

      if (newEntries.isEmpty) {
        _layersTransition = _LayersTransition.pushFromOrPopToEmpty;
        _hiddenEntry = null;
        _visibleEntry = oldEntries.last;
        _controller.reverse(from: 1.0).then((_) {
          _layersTransition = _LayersTransition.idleAtRoot;
          _visibleEntry = null;
        });
        return;
      }

      if (oldEntries.last == newEntries.last) {
        return;
      }

      final lengthDiff = newEntries.length - oldEntries.length;
      if (lengthDiff == 1 && (oldEntries.last == newEntries[oldEntries.length - 2])) {
        _layersTransition = _LayersTransition.push;
        _hiddenEntry = oldEntries.last;
        _visibleEntry = newEntries.last;
        _controller.forward(from: 0.0).then((_) {
          _layersTransition = _LayersTransition.idleAtEntry;
          _hiddenEntry = null;
          _visibleEntry = null;
        });
        return;
      }

      if (lengthDiff == -1 && (oldEntries[oldEntries.length - 2] == newEntries.last)) {
        _layersTransition = _LayersTransition.pop;
        _hiddenEntry = newEntries.last;
        _visibleEntry = oldEntries.last;
        _controller.reverse(from: 1.0).then((_) {
          _layersTransition = _LayersTransition.idleAtEntry;
          _hiddenEntry = null;
          _visibleEntry = null;
        });
        return;
      }
      
      _layersTransition = _LayersTransition.replace;
      _replacedEntriesLength = oldEntries.length;
      _hiddenEntry = oldEntries.last;
      _visibleEntry = newEntries.last;
      _controller.forward(from: 0.0).then((_) {
        _layersTransition = _LayersTransition.idleAtEntry;
        _hiddenEntry = null;
        _visibleEntry = null;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[
      widget.rootLayer
    ];
    if (_visibleEntry != null || _entries.isNotEmpty) {
      final ShellEntryComponents? hiddenComponents;
      if (_hiddenEntry != null) {
        hiddenComponents = _hiddenEntry!.build(context);
      } else if (_entries.length > 2) {
        hiddenComponents = _entries[_entries.length - 2].build(context);
      } else {
        hiddenComponents = null;
      }

      final ShellEntryComponents visibleComponents;
      if (_visibleEntry != null) {
        visibleComponents = _visibleEntry!.build(context);
      } else {
        visibleComponents = _entries.last.build(context);
      }

      layers.add(_TitleLayer(
          hiddenComponents: hiddenComponents,
          visibleComponents: visibleComponents,
          animation: _controller,
          layersTransition: _layersTransition,
          replacedEntriesLength: _replacedEntriesLength,
          entriesLength: _entries.length));
    }
    return Stack(children: layers);
  }
}
