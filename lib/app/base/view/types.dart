import 'package:flutter/widgets.dart';

import '../model.dart';

typedef ContextCallback = void Function(BuildContext context);

typedef AnimatedWidgetBuilder = Widget Function(BuildContext context, Animation<double> animation);

typedef ModelWidgetBuilder<M extends Model> = Widget Function(BuildContext context, M model);