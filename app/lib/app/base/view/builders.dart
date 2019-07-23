import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'types.dart';

abstract class _Listener extends StatefulWidget {

  _Listener({ Key key, this.listenable }) : super(key: key);

  final Listenable listenable;

  @override
  _ListenerState createState();
}

abstract class _ListenerState<W extends _Listener> extends State<W> {

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.listenable?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    oldWidget.listenable?.removeListener(_rebuild);
    super.didUpdateWidget(oldWidget);
    widget.listenable?.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.listenable?.removeListener(_rebuild);
    super.dispose();
  }
}

class ValueChangeBuilder<T> extends _Listener {

  ValueChangeBuilder({
    Key key,
    ValueListenable<T> valueListenable,
    this.builder,
    this.child
  }) : super(key: key, listenable: valueListenable);

  @override
  ValueListenable<T> get listenable => super.listenable;

  final ValueWidgetBuilder<T> builder;
  final Widget child;

  @override
  _ValueChangeBuilderState<T> createState() => _ValueChangeBuilderState<T>();
}

class _ValueChangeBuilderState<T> extends _ListenerState<ValueChangeBuilder<T>> {

  T _value;

  @override
  void _rebuild() {
    final T newValue = widget.listenable.value;
    if (newValue != _value) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _value = widget.listenable.value;
  }

  @override
  void didUpdateWidget(ValueChangeBuilder<T> oldWidget) { 
    super.didUpdateWidget(oldWidget);
    _value = widget.listenable.value;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}

class ValueBuilder<T> extends _Listener {

  ValueBuilder({
    Key key,
    @required this.valueGetter,
    Listenable listenable,
    @required this.builder,
    this.child,
  }) : super(
    key: key,
    listenable: listenable
  );

  final ValueGetter<T> valueGetter;

  final ValueWidgetBuilder<T> builder;

  final Widget child;

  @override
  _ValueBuilderState<T> createState() => _ValueBuilderState<T>();
}

class _ValueBuilderState<T> extends _ListenerState<ValueBuilder<T>> {

  T value;

  Widget child;

  @override
  void didUpdateWidget(ValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    child = null;
  }

  @override
  void reassemble() {
    super.reassemble();
    child = null;
  }

  @override
  Widget build(BuildContext context) {
    final T oldValue = value;
    value = widget.valueGetter();
    if (child == null || value != oldValue) {
      child = widget.builder(context, value, widget.child);
    }
    return child;
  }
}