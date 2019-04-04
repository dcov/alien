import 'dart:async';

import 'package:reddit/reddit.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'comment.dart';
import 'more.dart';
import 'param.dart';
import 'refreshable.dart';
import 'thing.dart';

class LinkCommentsModelSideEffects with RedditMixin {

  const LinkCommentsModelSideEffects();

  CommentModel createCommentModel(Comment comment) {
    return CommentModel(comment);
  }

  ParamModel<CommentsSort> createCommentsSortModel(
    CommentsSort sort,
    Iterable<CommentsSort> values,
    VoidCallback onSortUpdated,
  ) {
    return ParamModel(
      sort,
      values,
      onSortUpdated,
    );
  }

  MoreModel createMoreModel(
    More thing,
    String fullLinkId,
    TreeUpdater onMoreComments,
  ) {
    return MoreModel(
      thing,
      fullLinkId,
      onMoreComments,
    );
  }

  Future<Iterable<Thing>> getLinkComments(String permalink, CommentsSort sort) {
    return getInteractor().getLinkComments(
      permalink: permalink,
      sort: sort
    ).then((listing) => listing.things);
  }
}

class LinkCommentsModel extends RefreshableThingsModel {

  LinkCommentsModel(
    this._fullLinkId,
    this._permalink, [
    CommentsSort suggestedSort = CommentsSort.best,
    this._sideEffects = const LinkCommentsModelSideEffects(),
  ]) {
    _sort = _sideEffects.createCommentsSortModel(
      suggestedSort,
      CommentsSort.values,
      refresh
    );
  }

  ParamModel<CommentsSort> get sort => _sort;
  ParamModel<CommentsSort>_sort;

  final String _fullLinkId;
  final String _permalink;
  final LinkCommentsModelSideEffects _sideEffects;

  @override
  Future<Iterable<Thing>> loadItems() {
    return _sideEffects.getLinkComments(_permalink, _sort.param);
  }

  @override
  Model createItem(Thing thing) {
    if (thing is Comment) {
      return _sideEffects.createCommentModel(thing);
    } else if (thing is More && MoreModel.ensureThingContainsReferences(thing)) {
      return _sideEffects.createMoreModel(
        thing,
        _fullLinkId,
        _insertMore
      );
    }
    return null;
  }

  @override
  Iterable<Model> mapItems(Iterable<Thing> items, [ List<ThingModelMixin> list ]) {
    list ??= List<ThingModelMixin>();
    for (final thing in items) {
      final Model model = createItem(thing);
      if (model != null)
        list.add(model);
      if (thing is Comment && thing.replies != null) {
        mapItems(thing.replies, list);
      }
    }
    return list;
  }

  void _insertMore(MoreModel parent, Iterable<Thing> things) {
    final index = childList.indexOf(parent);
    final newModels = mapItems(things);
    childList.replaceRange(index, index + 1, newModels);
    notifyListeners();
  }
}

class LinkCommentsScrollView extends View<LinkCommentsModel> {

  LinkCommentsScrollView({
    Key key,
    @required this.heading,
    @required LinkCommentsModel model
  }) : super(key: key, model: model);

  final Widget heading;

  @override
  _LinkCommentsScrollViewState createState() => _LinkCommentsScrollViewState();
}

class _LinkCommentsScrollViewState extends RefreshableScrollViewState<LinkCommentsModel, LinkCommentsScrollView> {

  @override
  SliverChildDelegate getChildDelegate(BuildContext context) {
    return SliverHeadingChildBuilderDelegate(
      heading: Material(child: widget.heading),
      builder: (BuildContext context, int index) {
        return buildChild(context, model.children[index]);
      },
      childCount: model.children.length
    );
  }
  
  @override
  Widget buildChildList({ Key key }) {
    return SliverCustomPaint(
      painter: const _DepthIndicatorPainter(),
      sliver: super.buildChildList(),
    );
  }

  @override
  Widget buildChild(BuildContext context, Model child) {
    if (child is CommentModel) {
      return CommentTile(
        includeDepthPadding: true,
        model: child,
      );
    } else if (child is MoreModel) {
      return MoreTile(model: child);
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return buildScrollView(context);
  }
}

class _DepthIndicatorPainter extends CustomPainter {

  static const _lineCount = 10;
  static const _minOpacity = 0.25;
  static const _opacityIncrementRatio = 1.0 - _minOpacity;

  const _DepthIndicatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double startDy = 0.0;
    final double endDy = size.height;
    final Paint paint = Paint();
    for (int i = 1; i <= _lineCount; i++) {
      final double dx = Insets.fullAmount * i;
      paint..color = Colors.grey.withOpacity(_minOpacity + (i / _lineCount * _opacityIncrementRatio));
      canvas.drawLine(
        Offset(dx, startDy),
        Offset(dx, endDy),
        paint
      );
    }
  }

  @override
  bool shouldRepaint(_DepthIndicatorPainter oldDelegate) {
    return false;
  }
}