import 'package:loux/loux.dart';

class ToggleSaved extends Event {

  ToggleSaved({
    this.key
  });

  final ModelKey key;

  @override
  Effect update(Store store) {
    return null;
  }
}
