import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart';

part 'theming.mdl.dart';

enum ThemeType {
  light,
  dark
}

@model
mixin $Theming {

  ThemeData data;

  ThemeType type;
}

mixin ThemingOwner {
  $Theming get theming;
}

