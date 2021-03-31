import 'package:flutter/material.dart';

import '../models/app.dart';
import '../ui/theming.dart';

ThemingData _createThemingData(AppTheme theme) {
  switch (theme) {
    case AppTheme.dark:
      return ThemingData(
        canvasColor: Colors.grey[900]!,
        altCanvasColor: Colors.grey[850]!,
        borderColor: Colors.grey[850]!,
        altBorderColor: Colors.grey[600]!,
        dividerColor: Colors.grey[800]!,
        iconColor: Colors.grey[50]!,
        headerText: TextStyle(
          color: Colors.grey[50]!,
          fontSize: 16.0,
          fontWeight: FontWeight.w500),
        titleText: TextStyle(
          color: Colors.grey[50]!,
          fontSize: 14.0,
          fontWeight: FontWeight.w500),
        disabledTitleText: TextStyle(
          color: Colors.grey[400]!,
          fontSize: 14.0,
          fontWeight: FontWeight.w500),
        bodyText: TextStyle(
          color: Colors.grey[50]!,
          fontSize: 14.0,
          fontWeight: FontWeight.w400),
        detailText: TextStyle(
          color: Colors.grey[400]!,
          fontSize: 12.0,
          fontWeight: FontWeight.w400),
        captionText: TextStyle(
          color: Colors.grey[50]!,
          fontSize: 10.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0));
  }
}

class Themer extends StatelessWidget {

  Themer({
    Key? key,
    required this.theme,
    required this.child
  }) : super(key: key);

  final AppTheme theme;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theming(
      data: _createThemingData(theme),
      child: child);
  }
}
