import 'package:flutter/material.dart' show ThemeData;
import 'package:muex/muex.dart';
import 'package:meta/meta.dart';

import '../models/theming.dart';

class UpdateTheme implements Update {

  UpdateTheme({
    @required this.theming,
    this.type = ThemeType.light
  });

  final Theming theming;

  final ThemeType type;

  @override
  Then update(_) {
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

      return Then.done();
  }
}

