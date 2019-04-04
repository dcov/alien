import 'package:reddit/values.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'saveable.dart';
import 'snudown.dart';
import 'thing.dart';
import 'votable.dart';

class CommentModelSideEffects {

  const CommentModelSideEffects();

  SnudownModel createSnudownModel(String data) {
    return SnudownModel(data);
  }
}

class CommentModel extends Model with ThingModelMixin, VotableModelMixin, SaveableModelMixin {

  CommentModel(Comment thing, [ this._sideEffects = const CommentModelSideEffects() ]) {
    _authorFlairText = thing.authorFlairText;
    _authorName = thing.authorName;
    _createdUtc = thing.createdUtc;
    _depth = thing.depth;
    _editedUtc = thing.editedUtc;
    _isSubmitter = thing.isSubmitter;

    if (thing.body != null && thing.body.isNotEmpty) {
      _body = _sideEffects.createSnudownModel(thing.body);
    }

    initThingModel(thing);
    initVotableModel(thing);
    initSaveableModel(thing);
  }

  String get authorFlairText => _authorFlairText;
  String _authorFlairText;

  String get authorName => _authorName;
  String _authorName;

  SnudownModel get body => _body;
  SnudownModel _body;

  int get createdUtc => _createdUtc;
  int _createdUtc;

  int get depth => _depth;
  int _depth;

  int get editedUtc => _editedUtc;
  int _editedUtc;

  bool get isSubmitter => _isSubmitter;
  bool _isSubmitter;

  final CommentModelSideEffects _sideEffects;

  @override
  void didMatchThing(Comment thing) {
    super.didMatchThing(thing);
  }
}

class CommentTile extends StatelessWidget {

  CommentTile({
    Key key,
    this.includeDepthPadding,
    this.model
  }) : super(key: key);

  final bool includeDepthPadding;
  final CommentModel model;

  @override
  Widget build(BuildContext context) {
    Widget result = Material(
      child: Padding(
        padding: Insets.fullAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: CircleDivider.insert(<Widget>[
                CaptionText(model.authorName, color: model.isSubmitter ? Colors.blue : null),
                CaptionText(formatElapsedUtc(model.createdUtc)),
                CaptionText(formatCount(model.score)),
            ])),
            Padding(
              padding: Insets.quarterTop,
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.body1,
                child: Snudown(
                  scrollable: false,
                  model: model.body,
                ),
              )
            )
          ]
        )
      )
    );

    if (includeDepthPadding) {
      result = Padding(
        padding: EdgeInsets.only(left: (Insets.fullAmount * model.depth ) + 1),
        child: result,
      );
    }

    return result;
  }
}