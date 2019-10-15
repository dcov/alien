import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

class PushNotification extends Notification {

  const PushNotification();
}

extension PushExtension on BuildContext {

  void dispatch(Event event) {
    LoopScope.dispatch(this, event);
    const PushNotification().dispatch(this);
  }
}
