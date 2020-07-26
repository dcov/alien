import '../models/thing_model.dart';

/// Converts [Thing.id] into a 'full' id by prefixing it with [Thing.kind].
/// 
/// This is method is useful when calling certain Reddit endpoints that require
/// a 'full' id.
String makeFullId(Thing thing) {
  return '${thing.kind}_${thing.id}';
}
