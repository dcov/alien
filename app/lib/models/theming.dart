import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart';

part 'theming.g.dart';

@abs
abstract class RootTheming implements Model {
  Theming get theming;
}

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
