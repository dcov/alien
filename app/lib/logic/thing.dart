import '../models/thing.dart';

extension ThingExtensions on Thing {

  /// Converts [this.id] into a 'full' id by prefixing it with [this.kind].
  /// 
  /// This getter is useful when calling certain Reddit endpoints that require
  /// a 'full' id.
  String get fullId => '${this.kind}_${this.id}';
}
