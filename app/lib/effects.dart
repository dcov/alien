import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';

void runLoopWithEffects({
  @required String appId,
  @required String appRedirect,
  @required Initial initial,
  Set<ProxyUpdate> proxies,
  @required Widget view,
}) {
  final GlobalKey<EffectRendererState> rendererKey = GlobalKey<EffectRendererState>();
  runLoop(
    initial: initial,
    container: EffectContext(
      appId: appId,
      appRedirect: appRedirect,
      rendererKey: rendererKey),
    proxies: proxies,
    view: EffectRenderer(
      key: rendererKey,
      child: view));
}

class EffectContext {

  factory EffectContext({
    @required String appId,
    @required String appRedirect,
    @required GlobalKey<EffectRendererState> rendererKey
  }) {
    return EffectContext._(
      Reddit(appId, appRedirect),
      Hive,
      Scraper(),
      rendererKey,
    );
  }

  EffectContext._(
    this.reddit,
    this.hive,
    this.scraper,
    this._rendererKey
  );

  final Reddit reddit;

  final HiveInterface hive;

  final Scraper scraper;

  EffectRendererState get renderer => _rendererKey.currentState;
  final GlobalKey<EffectRendererState> _rendererKey;
}

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

