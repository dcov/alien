import 'dart:async';

import 'package:meta/meta.dart';
import 'package:reddit/values.dart';

import 'base.dart';
import 'thing.dart';

class SaveableModelSideEffects with RedditMixin {

  const SaveableModelSideEffects();

  Future<void> postSave(String fullThingId) {
    return getInteractor().postSave(fullThingId: fullThingId);
  }

  Future<void> postUnsave(String fullThingId) {
    return getInteractor().postUnsave(fullThingId: fullThingId);
  }
}

mixin SaveableModelMixin on ThingModelMixin {

  @protected
  void initSaveableModel(
    Saveable thing, [
    SaveableModelSideEffects sideEffects = const SaveableModelSideEffects()
  ]) {
    _isSaved = thing.isSaved;
    _sideEffects = sideEffects;
  }

  bool get isSaved => _isSaved;
  bool _isSaved;

  SaveableModelSideEffects _sideEffects;

  void save() {
    if (isSaved == null)
      return;

    if (isSaved) {
      _isSaved = false;
      _sideEffects.postUnsave(fullId).catchError((error) {
      });
    } else {
      _isSaved = true;
      _sideEffects.postSave(fullId).catchError((error) {
      });
    }
    notifyListeners();
  }

  @override
  void didMatchThing(Thing thing) {
    super.didMatchThing(thing);
    Saveable saveable = thing;
    _isSaved = saveable.isSaved;
  }
}