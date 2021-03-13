import 'package:flutter/material.dart';

class ThemingData {

  const ThemingData({
    required this.canvasColor,
    required this.altCanvasColor,
    required this.borderColor,
    required this.dividerColor,
    required this.iconColor,
    required this.headerText,
    required this.titleText,
    required this.disabledTitleText,
    required this.bodyText,
    required this.detailText,
    required this.captionText
  });

  final Color canvasColor;

  final Color altCanvasColor;

  final Color borderColor;

  final Color dividerColor;

  final Color iconColor;

  final TextStyle headerText;

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
