import 'package:flutter/widgets.dart';

class IgnoredDecoration extends StatelessWidget {

  IgnoredDecoration({
    Key? key,
    required this.decoration,
    required this.child
  }) : super(key: key);

  final BoxDecoration decoration;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: true,
          child: DecoratedBox(
            decoration: decoration,
            child: const SizedBox.expand())),
        child
      ]);
  }
}
