import 'package:flutter/material.dart';

extension NavigatorExtensions on BuildContext {

  Future<T> push<T>(Route<T> route) => Navigator.push(this, route);

  bool pop<T>([T result]) => Navigator.pop(this, result);
}

extension MediaQueryExtensions on BuildContext {

  EdgeInsets get mediaPadding {
    return MediaQuery.of(this).padding;
  }
}

extension ThemeExtensions on BuildContext {

  ThemeData get theme => Theme.of(this);
}

