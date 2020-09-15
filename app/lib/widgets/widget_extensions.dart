import 'package:flutter/material.dart';

extension MediaQueryExtensions on BuildContext {

  EdgeInsets get mediaPadding {
    return MediaQuery.of(this).padding;
  }
}

extension ThemeExtensions on BuildContext {

  ThemeData get theme => Theme.of(this);
}

