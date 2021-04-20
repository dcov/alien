import 'package:flutter/material.dart';

class ThemingData {

  const ThemingData({
    required this.canvasColor,
    required this.altCanvasColor,
    required this.borderColor,
    required this.altBorderColor,
    required this.dividerColor,
    required this.iconColor,
    required this.headerText,
    required this.altHeaderText,
    required this.titleText,
    required this.disabledTitleText,
    required this.bodyText,
    required this.detailText,
    required this.captionText
  });

  final Color canvasColor;

  final Color altCanvasColor;

  final Color borderColor;

  final Color altBorderColor;

  final Color dividerColor;

  final Color iconColor;

  final TextStyle headerText;

  final TextStyle altHeaderText;

  final TextStyle titleText;

  final TextStyle disabledTitleText;

  final TextStyle bodyText;

  final TextStyle detailText;

  final TextStyle captionText;
}

class Theming extends InheritedWidget {

  const Theming({
    Key? key,
    required this.data,
    required Widget child
  }) : super(key: key, child: child);

  final ThemingData data;

  static ThemingData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Theming>()!.data;
  }

  @override
  bool updateShouldNotify(Theming oldWidget) {
    return this.data != oldWidget.data;
  }
}

enum ThemeKind {
  dark
}

ThemingData _createThemingData(ThemeKind kind) {
  switch (kind) {
    case ThemeKind.dark:
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
        altHeaderText: TextStyle(
          color: Colors.grey[50]!,
          fontSize: 14.0,
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
    required this.kind,
    required this.child
  }) : super(key: key);

  final ThemeKind kind;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theming(
      data: _createThemingData(kind),
      child: child);
  }
}
