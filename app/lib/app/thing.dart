import 'package:meta/meta.dart';
import 'package:reddit/values.dart';

import 'base.dart';

mixin ThingModelMixin on Model {

  @protected
  void initThingModel(Thing thing) {
    _fullId = thing.fullId;
  }

  String get fullId => _fullId;
  String _fullId;

  bool matchThing(Thing thing) {
    if (this.fullId == thing.fullId) {
      didMatchThing(thing);
      return true;
    }
    return false;
  }

  @protected
  void didMatchThing(covariant Thing thing) { }
}