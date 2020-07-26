import 'package:elmer/elmer.dart';
import 'package:flutter/material.dart' show ThemeData;
import 'package:meta/meta.dart';

import '../models/theming_model.dart';

class UpdateTheme implements Event {

  const UpdateTheme({
    @required this.theming,
    this.type = ThemeType.light,
  });

  final Theming theming;

  final ThemeType type;

  @override
  void update(_) {
    theming
      ..data = () {
          switch (this.type) {
            case ThemeType.light:
              return ThemeData.light();
            case ThemeType.dark:
              return ThemeData.dark();
          }
          return null;
        }()
      ..type  = this.type;
  }
}
