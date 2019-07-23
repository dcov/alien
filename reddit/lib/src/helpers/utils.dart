import 'package:reddit/values.dart';

String makeIdFromFullId(String fullId) {
  final int index = fullId.indexOf('_');
  return fullId.substring(index + 1);
}

/// Converts the provided [Thing.id] into a [Thing.fullId] based on the
/// specified [Type]. The [Type] must be a subtype of [Thing].
String makeFullIdFromIdOfKind(String id, Type type) {
  switch (type) {
    case Comment:
      return 't1_$id';
    case Account:
      return 't2_$id';
    case Link:
      return 't3_$id';
    case Message:
      return 't4_$id';
    case Subreddit:
      return 't5_$id';
    case More:
      return 'more_$id';
    default:
      throw ArgumentError('$type is not a subtype of Thing.');
  }
}

Iterable<Thing> flattenLinkComments(Iterable<Thing> things, [List<Thing> addTo]) {
  addTo ??= new List<Thing>();
  for (final thing in things) {
    addTo.add(thing);
    if (thing is Comment && thing.replies != null) {
      flattenLinkComments(thing.replies, addTo);
    }
  }
  return addTo;
}