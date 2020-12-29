import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:meta/meta.dart';

import '../models/theming.dart';

class UpdateTheme extends Action {

  UpdateTheme({
    @required this.theming,
    this.type = ThemeType.light
  });

  final Theming theming;

  final ThemeType type;

  @override
  dynamic update(_) {
    theming
      ..data = () {
          switch (type) {
            case ThemeType.light:
              return ThemeData.light();
            case ThemeType.dark:
              return ThemeData.dark();
          }
        }()
      ..type  = type;
  }
}

