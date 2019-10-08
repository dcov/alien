import 'package:flutter/widgets.dart';

EdgeInsets paddingWithLeftDepth(double padding, int depth) {
  return EdgeInsets.fromLTRB(
    padding * (1 + depth),
    padding,
    padding,
    padding,
  );
}
