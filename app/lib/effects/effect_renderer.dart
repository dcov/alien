import 'package:flutter/widgets.dart';

class EffectRenderer extends StatefulWidget {

  EffectRenderer({
    Key key,
    @required this.child
  }) : assert(child != null),
       super(key: key);

  final Widget child;

  @override
  EffectRendererState createState() => EffectRendererState();
}

class EffectRendererState extends State<EffectRenderer> {

  final Map<Object, Object> _children = Map<Object, Object>();

  Object withId(Object id) => _children[id];

  void _add(Object id, Object renderer) {
    assert(!_children.containsKey(id), 'Attempted to re-add a renderer with id: $id');
    _children[id] = renderer;
  }

  void _remove(Object id) {
    assert(_children.containsKey(id), 'Attempted to remove non existant renderer with id: $id');
    _children.remove(id);
  }

  @override
  Widget build(BuildContext context) {
    return _EffectRendererScope(
      state: this,
      child: widget.child,
    );
  }
}

class _EffectRendererScope extends InheritedWidget {

  _EffectRendererScope({
    Key key,
    @required this.state,
    Widget child,
  }) : assert(state != null),
       super(key: key, child: child);

  final EffectRendererState state;

  @override
  bool updateShouldNotify(_EffectRendererScope oldWidget) {
    return oldWidget.state != this.state;
  }
}

mixin EffectRendererMixin<W extends StatefulWidget> on State<W> {

  EffectRendererState _owner;

  @protected
  Object get rendererId;

  @protected
  Object get renderer => this;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _EffectRendererScope scope = context.dependOnInheritedWidgetOfExactType();
    assert(scope != null);
    if (scope.state != _owner) {
      _owner?._remove(rendererId);
      scope.state._add(rendererId, renderer);
      _owner = scope.state;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _owner?._remove(rendererId);
  }
}

