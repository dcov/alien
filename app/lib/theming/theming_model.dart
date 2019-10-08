part of 'theming.dart';

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
