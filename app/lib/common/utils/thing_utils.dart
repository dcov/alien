import '../../thing/thing.dart';

String makeFullId(Thing thing) {
  return '${thing.kind}_${thing.id}';
}
