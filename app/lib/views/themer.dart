import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mal_flutter/mal_flutter.dart';

import '../models/theming.dart';

class Themer extends StatefulWidget {

  Themer({
    Key key,
    @required this.theming,
    @required this.child,
  }) : super(key: key);

  final Theming theming;

  final Widget child;

  @override
  _ThemerState createState() => _ThemerState();
}
class _ThemerState extends State<Themer>
    with ConnectionStateMixin {

  ThemeType _themeType;
  ThemeData _themeData;
  SystemUiOverlayStyle _systemStyle;

  @override
  void capture(StateSetter setState) {
    final theming = widget.theming;
    if (_themeType != theming.type) {
      setState(() {
        _themeType = theming.type;
        _themeData = theming.data;

        switch (theming.type) {
          case ThemeType.light:
            _themeData = _themeData.copyWith(appBarTheme: _themeData.appBarTheme.copyWith(brightness: Brightness.light));
            _systemStyle = SystemUiOverlayStyle.dark;
            break;
          case ThemeType.dark:
            _themeData = _themeData.copyWith(appBarTheme: _themeData.appBarTheme.copyWith(brightness: Brightness.dark));
            _systemStyle = SystemUiOverlayStyle.light;
        }
      });
    }
  }

  @override
  Widget build(_) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemStyle,
      child: AnimatedTheme(
        data: _themeData,
        child: widget.child));
  }
}

