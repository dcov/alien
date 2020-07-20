import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:reddit/reddit.dart';
import 'package:scraper/scraper.dart';

import 'effect_renderer.dart';

class EffectContext {

  factory EffectContext({
    @required String redditId,
    @required String redditRedirect,
  }) {
    return EffectContext._(
      Reddit(redditId, redditRedirect),
      Hive,
      Scraper(),
      _defaultRenderer,
    );
  }

  EffectContext._(
    this.reddit,
    this.hive,
    this.scraper,
    this._renderer
  );

  final Reddit reddit;

  final HiveInterface hive;

  final Scraper scraper;

  EffectRendererState get renderer => _renderer();
  final ValueGetter<EffectRendererState> _renderer;

  /// Traverses down the [Element] tree from the root [Element] to find the
  /// [EffectRenderState].
  ///
  /// This is an O(1) operation in that it only has to traverse two levels down
  /// the [Element] tree from the root [Element] to find the [StatefulElement]
  /// that contains the [EffectRenderState].
  static EffectRendererState _defaultRenderer() {
    final Element rootElement = WidgetsBinding.instance.renderViewElement;

    /// [rootElement] only has one child, the [InheritedElement] that provides
    /// the [Loop], which is created by [runLoop]. [EffectRenderer] will be the
    /// child of this [Element].
    Element loopElement;
    rootElement.visitChildren((Element element) {
      assert(loopElement == null);
      assert(element is InheritedElement);
      loopElement = element;
    });

    /// [loopElement] only has one child, a [StatefulElement], which contains
    /// the [EffectRendererState].
    EffectRendererState result;
    loopElement.visitChildren((Element element) {
      assert(result == null);
      assert(element is StatefulElement);
      assert((element as StatefulElement).state is EffectRendererState);
      result = (element as StatefulElement).state;
    });

    assert(result != null,
        'EffectRenderer is not where it is expected. The most likely cause is '
        'that EffectRenderer wasn\'t the root Widget when calling runLoop.');

    return result;
  }
}

