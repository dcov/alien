import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {

  EdgeInsets get mediaPadding {
    return MediaQuery.of(this).padding;
  }

  ThemeData get theme => Theme.of(this);

  NavigatorState get navigator => Navigator.of(this);

  NavigatorState get rootNavigator => Navigator.of(this, rootNavigator: true);
}

extension AnimationExtensions on Animation {

  bool get isAnimating => !isDismissed && !isCompleted;
}
