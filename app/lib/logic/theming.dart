import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:meta/meta.dart';

import '../models/theming.dart';

@event
void updateTheme(_,
    { @required Theming theming, ThemeType type = ThemeType.light }) {

  theming
    ..data = () {
        switch (type) {
          case ThemeType.light:
            return ThemeData.light();
          case ThemeType.dark:
            return ThemeData.dark();
        }
        return null;
      }()
    ..type  = type;
}
