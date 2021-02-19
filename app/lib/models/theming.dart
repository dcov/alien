import 'package:muex/muex.dart';
import 'package:flutter/material.dart';

part 'theming.g.dart';

enum ThemeType {
  light,
  dark
}

abstract class Theming implements Model {

  factory Theming({
    ThemeData? data,
    ThemeType? type
  }) = _$Theming;

  ThemeData? get data;
  set data(ThemeData? value);

  ThemeType? get type;
  set type(ThemeType? value);
}

abstract class ThemingOwner {
  Theming get theming;
}
