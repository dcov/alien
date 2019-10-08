import 'package:elmer/elmer.dart';
import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/widgets.dart';

class PushNotification extends Notification {

  const PushNotification();

  static void notify(BuildContext context, Event event) {
    LoopScope.dispatch(context, event);
    const PushNotification().dispatch(context);
  }
}
