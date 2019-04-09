import 'dart:async';

import 'package:meta/meta.dart';
import 'package:reddit/values.dart';

import 'base.dart';
import 'thing.dart';

class VotableModelSideEffects with RedditMixin {

  const VotableModelSideEffects();

  Future<void> postUpvote(String fullThingId) {
    return getInteractor().postUpvote(fullThingId: fullThingId);
  }

  Future<void> postDownvote(String fullThingId) {
    return getInteractor().postDownvote(fullThingId: fullThingId);
  }

  Future<void> postUnvote(String fullThingId) {
    return getInteractor().postUnvote(fullThingId: fullThingId);
  }
}

mixin VotableModelMixin on ThingModelMixin {

  @protected
  void initVotableModel(
    Votable thing, [
    VotableModelSideEffects sideEffects = const VotableModelSideEffects()
  ]) {
    _downvoteCount = thing.downvoteCount;
    _isArchived = thing.isArchived;
    _isLiked = thing.isLiked;
    _isScoreHidden = thing.isScoreHidden;
    _score = thing.score;
    _upvoteCount = thing.upvoteCount;
    _sideEffects = sideEffects;
  }

  int get downvoteCount => _downvoteCount;
  int _downvoteCount;

  bool get isArchived => _isArchived;
  bool _isArchived;

  bool get isLiked => _isLiked;
  bool _isLiked;

  bool get isScoreHidden => _isScoreHidden;
  bool _isScoreHidden;

  int get score => _score;
  int _score;

  int get upvoteCount => _upvoteCount;
  int _upvoteCount;

  VotableModelSideEffects _sideEffects;

  void upvote() {
    if (isArchived)
      return;

    if (_isLiked == true) {
      _unvote();
      return;
    }

    _vote(
      newIsLiked: true,
      upvoteChange: 1,
      downvoteChange: _isLiked == false ? -1 : 0,
      sideEffect: _sideEffects.postUpvote
    );
  }

  void downvote() {
    if (isArchived)
      return;
    
    if (_isLiked == false) {
      _unvote();
      return;
    }

    _vote(
      newIsLiked: false,
      upvoteChange: _isLiked == true ? - 1 : 0,
      downvoteChange: 1,
      sideEffect: _sideEffects.postDownvote
    );
  }

  void _unvote() {
    if (isArchived || _isLiked == null)
      return;
    
    _vote(
      newIsLiked: null,
      upvoteChange: _isLiked == true ? -1 : 0,
      downvoteChange: _isLiked == false ? - 1 : 0,
      sideEffect: _sideEffects.postDownvote
    );
  }

  void _vote({
    bool newIsLiked,
    int upvoteChange,
    int downvoteChange,
    Future<void> sideEffect(String fullId)
  }) {
    final bool oldIsLiked = _isLiked;
    _isLiked = newIsLiked;
    _upvoteCount += upvoteChange;
    _downvoteCount += downvoteChange;
    _score = _score + upvoteChange - downvoteChange;
    sideEffect(fullId).catchError((error) {
      _isLiked = oldIsLiked;
      _upvoteCount -= upvoteChange;
      _downvoteCount -= downvoteChange;
      _score = _score - upvoteChange + downvoteChange;
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void didMatchThing(Thing thing) {
    super.didMatchThing(thing);
    Votable votable = thing;
    _downvoteCount = votable.downvoteCount;
    _isArchived = votable.isArchived;
    _isLiked = votable.isLiked;
    _isScoreHidden = votable.isScoreHidden;
    _score = votable.score;
    _upvoteCount = votable.upvoteCount;
  }
}