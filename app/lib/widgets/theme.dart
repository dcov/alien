import 'package:flutter/material.dart';

enum _CustomThemeDataType {
  dark
}

class CustomThemeData {

  factory CustomThemeData.dark() {
    return CustomThemeData._(_CustomThemeDataType.dark);
  }

  CustomThemeData._(
    this._type);

  final _CustomThemeDataType _type;
}

class CustomTheme extends InheritedWidget {

  CustomTheme({
    Key? key,
    required this.themeData,
    required Widget child
  }) : super(key: key, child: child);

  final CustomThemeData themeData;

  static CustomThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CustomTheme>()!.themeData;
  }

  @override
  bool updateShouldNotify(CustomTheme oldWidget) {
    return this.themeData._type != oldWidget.themeData._type;
  }
}
