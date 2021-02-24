import 'package:flutter/widgets.dart';

import 'widget_extensions.dart';

class Toolbar extends StatelessWidget {

  Toolbar({
    Key? key,
    this.leading,
    this.middle,
    this.trailing
  }) : super(key: key);

  static const kHeight = 48.0;

  final Widget? leading;

  final Widget? middle;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.mediaPadding.top),
      child: SizedBox(
        height: kHeight,
        child: NavigationToolbar(
          leading: leading,
          middle: middle,
          trailing: trailing)));
  }
}
