import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'thing.dart';

class MoreModelSideEffects with RedditMixin {

  const MoreModelSideEffects();

  Future<Iterable<Thing>> getMoreComments(
    String fullLinkId,
    String moreId,
    Iterable<String> thingIds
  ) {
    return getInteractor().getMoreComments(
      fullLinkId: fullLinkId,
      moreId: moreId,
      thingIds: thingIds
    ).then((listing) => listing.things);
  }
}

typedef TreeUpdater = void Function(MoreModel parent, Iterable<Thing> replaceWith);

class MoreModel extends Model with ThingModelMixin {

  MoreModel(
    More thing,
    this._fullLinkId,
    this._onUpdateTree, [
    this._sideEffects = const MoreModelSideEffects()
  ]) {
    _count = thing.thingIds.length;
    _depth = thing.depth;
    _thingIds = thing.thingIds;
    initThingModel(thing);
  }

  int get count => _count;
  int _count;

  int get depth => _depth;
  int _depth;
  
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  final String _fullLinkId;
  Iterable<String> _thingIds;
  final TreeUpdater _onUpdateTree;
  final MoreModelSideEffects _sideEffects;

  /// Checks whether [thing] actually contains references to more children. This
  /// is needed because on occasion the Reddit API will provide [More] values
  /// that don't contain any references and are thus useless.
  static bool ensureThingContainsReferences(More thing) {
    return thing.thingIds.isNotEmpty;
  }

  void loadMore() {
    if (_isLoading)
      return;
    _isLoading = true;
    notifyListeners();
    _sideEffects.getMoreComments(_fullLinkId, makeIdFromFullId(fullId), _thingIds).then(
      (things) => _onUpdateTree(this, things),
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  @override
  void didMatchThing(Thing thing) {
  }
}

class MoreTile extends StatelessWidget {

  MoreTile({ Key key, @required this.model })
    : super(key: key);

  final MoreModel model;
  
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: model,
    builder: (BuildContext context, _) {

      Widget child;
      if (model.isLoading) {
        child = Padding(
          padding: Insets.fullAll,
          child: CaptionText('Loading...'),
        );
      } else {
        child = InkWell(
          onTap: model.loadMore,
          child: Padding(
            padding: Insets.fullAll,
            child: CaptionText('Load ${model.count} comments'),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(
          left: (Insets.fullAmount * model.depth) + 1
        ),
        child: Material(
          child: child
        )
      );
    }
  );
}