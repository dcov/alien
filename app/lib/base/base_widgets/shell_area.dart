part of '../base.dart';

/// The shim between [ShellArea] and [ShellAreaEntry]s.
///
/// The [ShellArea] in scope can be modified by calling [push] or [pop] with
/// an [Object] that is either already a [ShellAreaEntry], or can be mapped to
/// a [ShellAreaEntry].
///
/// The default behavior, which is implemented by [ShellAreaState], only
/// accepts [ShellAreaEntry]s as values for either [push] or [pop].
abstract class ShellAreaController {

  /// Pushes a [ShellAreaEntry] mapping of [value] onto the [ShellArea] in
  /// scope.
  void push(covariant Object value);

  /// Pops a [ShellAreaEntry] mapping of [value] from the [ShellArea] in scope.
  /// If [value] isn't given, or it's null, the last [ShellAreaEntry] will be
  /// popped from the [ShellArea] stack.
  void pop([covariant Object value]);
}

abstract class ShellAreaEntry {

  String get title;

  List<Widget> buildTopActions(BuildContext context) => const <Widget>[];

  Widget buildBody(BuildContext context);

  List<Widget> buildBottomActions(BuildContext context) => const <Widget>[];
}

class ShellArea extends StatefulWidget {

  ShellArea({
    Key key,
    this.controller,
    this.initialEntries = const <ShellAreaEntry>[],
  }) : super(key: key);

  final ShellAreaController controller;

  final List<ShellAreaEntry> initialEntries;

  @override
  ShellAreaState createState() => ShellAreaState();
}

class ShellAreaState extends State<ShellArea>
    with TickerProviderStateMixin
    implements ShellAreaController {

  /// The current stack of [ShellAreaEntry]s.
  UnmodifiableListView<ShellAreaEntry> get entries => UnmodifiableListView<ShellAreaEntry>(_entries);

  Animation<double> get animation => _controller;

  List<ShellAreaEntry> _entries;
  List<ShellAreaEntry> _replacements;
  AnimationController _controller;

  /// Resets the [_controller] to a new [AnimationController], and disposes
  /// of the old [_controller] if it existed.
  ///
  /// This is called every time a call to [push], [pop], or [replace] happens
  /// to ensure that we've had a chance to render the new state at least once
  /// before we start animating.
  void _resetController({ double value: 0.0 }) {
    _controller?.dispose();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: value,
      vsync: this
    );
  }

  /// Adds [entry] to the end of the [entries] list, and starts a 'push'
  /// animation that animates [entry] in, and the now second-to-last
  /// [ShellAreaEntry] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  @override
  Future<void> push(ShellAreaEntry entry) async {
    assert(_controller?.isAnimating != true);
    setState(() {
      _entries.add(entry);
      _resetController();
    });
    try {
      await _controller.forward(from: 0.0).orCancel;
    } finally {
      // The animation completed, or the ticker was cancelled and we've caught
      // the error, we don't need to do anything else.
    }
  }

  /// Removes the last [ShellAreaEntry] in [entries], which is the currently
  /// visible [ShellAreaEntry], and starts a 'pop' animation that animates the
  /// last [ShellAreaEntry] out, and the second to last [ShellAreaEntry] in.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  @override
  Future<void> pop([ShellAreaEntry entry]) async {
    assert(_controller?.isAnimating != true);
    setState(() {
      _resetController();
    });
    try {
      await _controller.reverse(from: 1.0).orCancel;
    } finally {
      setState(() {
        // Reset the controller to value 1.0 to enable the drag-to-pop gesture.
        _resetController(value: 1.0);
        _entries.removeLast();
      });
    }
  }

  /// Replaces the current list of [ShellAreaEntry]s, [entries], with
  /// [replacements], and starts a 'replace' animation that animates the last,
  /// and second-to-last if it exists, [ShellAreaEntry]s in [replacements] in,
  /// and animates the last, and second-to-last if it exists, [ShellAreaEntry]s
  /// in the old [entries] out.
  ///
  /// It returns a [Future] that completes when the animation completes. It will
  /// never throw an error so it can be used safely with 'await'.
  Future<void> replace(List<ShellAreaEntry> replacements) async {
    assert(_controller?.isAnimating != true);
    assert(replacements.isNotEmpty);
    setState(() {
      _replacements = replacements;
      _resetController();
    });
    try {
      await _controller.forward(from: 0.0).orCancel;
    } finally {
      setState(() {
        _entries..clear()
                ..addAll(_replacements);
        _replacements = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _entries = List<ShellAreaEntry>();
    _entries.addAll(widget.initialEntries);
    _resetController(value: 1.0);
  }
  
  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty)
      return const SizedBox();

    final ShellAreaEntry primary = _entries.last;
    final ShellAreaEntry secondary = _entries.length > 1 ? _entries[_entries.length - 2] : null;
    final ShellAreaEntry ternary = _entries.length > 2 ? _entries[_entries.length - 3] : null;

    ShellAreaEntry replacementPrimary;
    ShellAreaEntry replacementSecondary;
    if (_replacements != null) {
      replacementPrimary = _replacements.last;
      replacementSecondary = _replacements.length > 1 ? _replacements[_replacements.length - 2] : null;
    }

    return _ShellAreaControllerScope(
      controller: widget.controller ?? this,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ShellAreaTopBar(
                onPop: widget.controller?.pop ?? pop,
                animation: _controller,
                primary: primary,
                secondary: secondary,
                // If we're rendering replacements, don't include the ternary entry.
                ternary: replacementPrimary != null ? null : ternary,
                replacementPrimary: replacementPrimary,
                replacementSecondary: replacementSecondary != secondary ? replacementSecondary : null,
              ),
              Expanded(
                child: ShellAreaBody(
                  animation: _controller,
                  isReplace: replacementPrimary != null,
                  primary: replacementPrimary ?? primary,
                  secondary: replacementPrimary != null ? primary : secondary,
                )
              ),
              ShellAreaBottomBar(
                animation: _controller,
                primary: replacementPrimary ?? primary,
                secondary: replacementPrimary != null ? primary : secondary,
                leading: const SizedBox(
                  width: _kButtonSize,
                  height: _kButtonSize,
                ),
              )
            ],
          ),
        ]
      )
    );
  }
}

class _ShellAreaControllerScope extends InheritedWidget {

  _ShellAreaControllerScope({
    Key key,
    @required this.controller,
    Widget child
  }) : assert(controller != null),
       super(key: key, child: child);

  final ShellAreaController controller;

  @override
  bool updateShouldNotify(_ShellAreaControllerScope oldWidget) {
    return oldWidget.controller != this.controller;
  }
}

extension ScopedShellAreaControllerExtensions on BuildContext {

  ShellAreaController get _controller {
    final _ShellAreaControllerScope scope = inheritFromWidgetOfExactType(_ShellAreaControllerScope);
    assert(scope != null);
    return scope.controller;
  }

  void push(Object value) => _controller.push(value);

  void pop(Object value) => _controller.pop(value);
}

