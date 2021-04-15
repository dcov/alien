import 'package:flutter/material.dart';

import '../ui/pressable.dart';
import '../ui/theming.dart';

class BackArrow extends StatelessWidget {

  BackArrow({
    Key? key,
    this.useRootNavigator = false,
    this.onPopResult,
  }) : super(key: key);

  final bool useRootNavigator;

  final ValueGetter<dynamic>? onPopResult;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return PressableIcon(
      onPress: () {
        final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
        final result = onPopResult != null ? onPopResult!() : null;
        navigator.pop(result);
      },
      icon: Icons.arrow_back_ios_rounded,
      iconColor: theming.iconColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0));
  }
}
