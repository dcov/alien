import 'package:muex/muex.dart';
import 'package:flutter/material.dart';

part 'theming.g.dart';

enum ThemeType {
  light,
  dark
}

abstract class Theming implements Model {

  factory Theming({
    ThemeData data,
    ThemeType type
  }) = _$Theming;

  ThemeData data;

  ThemeType type;
}

abstract class ThemingOwner {
  Theming get theming;
}

