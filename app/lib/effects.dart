import 'package:muex/muex.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';
import 'package:stash/stash_api.dart';

class _EffectRendererScope extends InheritedWidget {

  _EffectRendererScope({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final EffectRendererState state;

  @override
  bool updateShouldNotify(_EffectRendererScope oldWidget) {
    return oldWidget.state != this.state;
  }
}

class EffectRenderer extends StatefulWidget {

  EffectRenderer({
    Key? key,
    required this.child
  }) : super(key: key);

  final Widget child;

  @override
  EffectRendererState createState() => EffectRendererState();
}

class EffectRendererState extends State<EffectRenderer> {

  final Map<Object, Object> _children = Map<Object, Object>();

  Object withId(Object id) => _children[id]!;

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

mixin EffectRendererMixin<W extends StatefulWidget> on State<W> {

  EffectRendererState? _owner;

  @protected
  Object get rendererId;

  @protected
  Object get renderer => this; 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _EffectRendererScope? scope = context.dependOnInheritedWidgetOfExactType();
    assert(scope != null);
    if (scope!.state != _owner) {
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

class EffectContext {

  factory EffectContext({
    required String appId,
    required String appRedirect,
    String? scriptId,
    String? scriptSecret,
    String? scriptUsername,
    String? scriptPassword,
    required GlobalKey<EffectRendererState> rendererKey
  }) {
    late RedditClient client;
    if (scriptId != null) {
      client = createScriptClient(
        clientId: scriptId,
        clientSecret: scriptSecret!,
        username: scriptUsername,
        password: scriptPassword);
    }
    return EffectContext._(
      RedditApp(
        clientId: appId,
        redirectUri: appRedirect),
      client,
      Hive,
      Scraper(),
      rendererKey);
  }

  EffectContext._(
    this.redditApp,
    this.scriptClient,
    this.hive,
    this.scraper,
    this._rendererKey);

  final RedditApp redditApp;

  final RedditClient scriptClient;

  final HiveInterface hive;

  final Scraper scraper;

  late Cache cache;

  EffectRendererState get renderer => _rendererKey.currentState!;
  final GlobalKey<EffectRendererState> _rendererKey;
}

void runLoopWithEffects({
  required String appId,
  required String appRedirect,
  String? scriptId,
  String? scriptSecret,
  String? scriptUsername,
  String? scriptPassword,
  required Initial initial,
  required Widget view,
}) {
  final rendererKey = GlobalKey<EffectRendererState>();
  runLoop(
    initial: initial,
    container: EffectContext(
      appId: appId,
      appRedirect: appRedirect,
      rendererKey: rendererKey,
      scriptId: scriptId,
      scriptSecret: scriptSecret,
      scriptUsername: scriptUsername,
      scriptPassword: scriptPassword),
    view: EffectRenderer(
      key: rendererKey,
      child: view));
}
